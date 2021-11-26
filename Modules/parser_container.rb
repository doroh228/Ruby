require 'curb'
require 'nokogiri'
require 'csv'
require 'ruby-progressbar'
require_relative '../Models/product'
require 'yaml'

module ParserContainer

  private

  def load_yaml_params
    @params = YAML.load_file('params.yml')
  end

  def load_url(url)
    http = Curl.get(url) do |curl|
      curl.ssl_verify_peer=false
      curl.ssl_verify_host=0
    end
    Nokogiri::HTML(http.body_str)
  end

  def countOfPages ()
    # How many pages
    countOfProducts = @main_html.xpath(@params['xpath']['count_products']).text.to_i
    res =(countOfProducts/@params['products_on_page'].to_f).ceil
    if (res>0)
      return res
    else
      return 1
    end
  end

  def getFromPageHTML(url,page_n)
    # open html with select page
    if(page_n == 1)
      return @main_html
    else
      return load_url(url + "?p=" + page_n.to_s)
    end
  end

  def getLinksFromPage(html_page)
    # gets links from select url
    links = []
    html_page.xpath(@params['xpath']['product_url']).each do|link|
      links << link.content
    end
    return links
  end

  def getAllLinksOnProducts(url)
    # Get all links on products
    countOfPage = countOfPages()
    progressbar = ProgressBar.create(title: "Data Collection", format: "%t %c/%C links: |%b>%i| %E", total: (countOfPage*25))
    links =[]
    for i in (1..countOfPages())
      html_selectPage = getFromPageHTML(url,i)
      links+=getLinksFromPage(html_selectPage)
      25.times { progressbar.increment }
    end
    return links
  end

  def getDataAboutProduct(url)
    # collect information about product from single page
    htmlSelectPtoduct = load_url(url)
    title = htmlSelectPtoduct.xpath(@params['xpath']['product_title']).text.to_s.strip
    image = htmlSelectPtoduct.xpath(@params['xpath']['product_img']).map { |p| p.text }
    criteria = htmlSelectPtoduct.xpath(@params['xpath']['product_criteria']).map { |p| p.text }
    prices = htmlSelectPtoduct.xpath(@params['xpath']['product_price']).map { |p| p.text.to_s.delete("€").strip }
    products = []
    (0...criteria.length).each do |i|
      products << Product.new(criteria[i].nil? ? title : title + ' - ' + criteria[i], prices[i],image[0])
    end
    return products
  end

  def get_thrds_on_prod(allLinks, name_Csv_File)
    #get all threads on our products
    threads = []
    allLinks.each do |link|
      threads << Thread.new do
        result = getDataAboutProduct(link)
        result.each { |product|   product.save(name_Csv_File)}
        @total_items += result.length
        @progressbar.increment
      end
    end
    return threads
  end

end