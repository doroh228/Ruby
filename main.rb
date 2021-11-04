require 'curb'
require 'nokogiri'
require 'csv'
require 'open-uri'
require 'ruby-progressbar'
#require_relative ''

$select_url =""

def load_url(url)
  $select_url = url
  return Nokogiri::HTML(Curl.get(url).body_str)
end
def loadUrlWithPage(url) # Get HTML code
  return Nokogiri::HTML(URI.open(url))
end
def countOfPages (url) # How many pages
  countOfProducts = load_url(url).xpath("//input[@id = 'nb_item_bottom']/@value").text.to_i
  return (countOfProducts/25.00).ceil
end

def urlPage(url,page_n) # open html with select page
  loadUrlWithPage("#{url}?p=#{page_n.to_s}")
end

def getLinksFromPage(url_page) # gets links from select url
  links = []
  url_page.xpath("//div[@class='product-desc display_sd']//a//@href").each do|link|
    links << link.content
  end
  return links
end
def getsAllLinksOnProduts() # Get all links on products
  links =[]
  for i in (1..countOfPages($select_url))
    url_selectPage = urlPage($select_url,i)
    links+=getLinksFromPage(url_selectPage)
  end
  return links
end

def getDataAboutProduct(url)
  htmlSelectPtoduct = loadUrlWithPage(url)
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

=begin
load_url(urlCategory)
links = getsAllLinksOnProduts()

total_items = 0
=end
=begin

progressbar = ProgressBar.create(title: "Grabbed", format: "%t %c/%C products: |%b>%i| %E", total: links.length)
=end
=begin
column_header = ["Name","Price","Image"]
CSV.open(csv_file, "w", :write_headers=> true, :headers => column_header) {}
=end


=begin
links.each do |link|
  result = getDataAboutProduct(link)
  CSV.open(csv_file, "a",) do |csv|
    result.each do |p|
      res = [p[:title], :price, :image]
      csv << res
    end
  end
  total_items += result.length
  progressbar.increment
end
=end

CSV.open('test.csv','w',    :write_headers=> true,    :headers => ["numerator","denominator","calculation"] ) do|hdr|
  1.upto(12){|numerator|
    1.upto(12){ |denominator|
      data_out = [numerator, denominator, numerator/denominator.to_f]
      hdr << data_out
    }
  }end
=begin
puts "Grabbed #{total_items} items from #{links.length} product pages"=end
