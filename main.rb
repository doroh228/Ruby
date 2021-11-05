require 'curb'
require 'nokogiri'
require 'csv'
require 'open-uri'
require 'ruby-progressbar'
#require_relative ''

$select_url =""

def load_url(url)
  http = Curl.get(url) do |curl|
    curl.ssl_verify_peer=false
    curl.ssl_verify_host=0
  end
  Nokogiri::HTML(http.body_str)
end

def load_selected_url(url)
  $select_url = load_url(url)
end

def loadUrlWithPage(url)
  # Get HTML code
  return Nokogiri::HTML(URI.open(url))
end

def countOfPages ()
  # How many pages
  countOfProducts = $select_url.xpath("//input[@id = 'nb_item_bottom']/@value").text.to_i
  res =(countOfProducts/25.00).ceil
  if (res>0)
    return res
  else
    return 1
  end
end

def urlPage(url,page_n)
  # open html with select page
  if page_n == 1
    return load_url(url)
  else
    return load_url(url + "?p=" + page_n.to_s)
  end
end

def getLinksFromPage(url_page)
  # gets links from select url
  links = []
  url_page.xpath("//div[@class='product-desc display_sd']//a//@href").each do|link|
    links << link.content
  end
  return links
end

def getsAllLinksOnProduts(url)
  # Get all links on products
  links =[]
  for i in (1..countOfPages())
    url_selectPage = urlPage(url,i)
    links+=getLinksFromPage(url_selectPage)
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

if ARGV.length != 2
  puts "Wrong number of arguments(given #{ARGV.length}, expected 2) (ArgumentError)"
  exit
end

urlCategory = ARGV[0]
csv_file = ARGV[1]

load_selected_url(urlCategory)
links = getsAllLinksOnProduts(urlCategory)

total_items = 0

progressbar = ProgressBar.create(title: "Grabbed", format: "%t %c/%C products: |%b>%i| %E", total: links.length)

CSV.open(csv_file, "w", :write_headers=> true, :headers => ["Name","Price","Image"]) {}

links.each do |link|
  result = getDataAboutProduct(link)
  CSV.open(csv_file, "a",) do |csv|
    result.each do |p|
      csv << [p[:title], p[:price], p[:image]]
    end
  end
  total_items += result.length
  progressbar.increment
end

puts "Grabbed #{total_items} items from #{links.length} product pages"
