require 'curb'
require 'nokogiri'
require 'csv'
require 'ruby-progressbar'

module ParserContainer

  private
  def load_url(url)
    http = Curl.get(url) do |curl|
      curl.ssl_verify_peer=false
      curl.ssl_verify_host=0
    end
    Nokogiri::HTML(http.body_str)
  end

  def countOfPages ()
    # How many pages
    countOfProducts = @main_html.xpath("//input[@id = 'nb_item_bottom']/@value").text.to_i
    res =(countOfProducts/25.00).ceil
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
    html_page.xpath("//div[@class='product-desc display_sd']//a//@href").each do|link|
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
    htmlSelectPtoduct = load_url(url)
    title = htmlSelectPtoduct.xpath("//div[@class='nombre_fabricante_bloque col-md-12 desktop']//h1").text.to_s.strip
    image = htmlSelectPtoduct.xpath("//div[@id='image-block']//img//@src").map { |p| p.text }
    criteria = htmlSelectPtoduct.xpath("//ul[@class='attribute_radio_list pundaline-variations']//li//span[@class='radio_label']").map { |p| p.text }
    prices = htmlSelectPtoduct.xpath("//ul[@class='attribute_radio_list pundaline-variations']//li//span[@class='price_comb']").map { |p| p.text.to_s.delete("€").strip }
    products = []
    (0...criteria.length).each do |i|
      products.push({
                      title: criteria[i].nil? ? title : title + ' - ' + criteria[i],
                      price: prices[i],
                      image: image[0],
                    })
    end
    return products
  end
end