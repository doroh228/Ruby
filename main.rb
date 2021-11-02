require 'curb'
require 'nokogiri'
require 'csv'
require 'open-uri'
#require_relative ''

select_url ='https://www.petsonic.com/farmacia-para-gatos/'

def load_url(url)
  return Nokogiri::HTML(URI.open(url))
end

def countOfPages (url) # How many pages
  countOfProducts = load_url(url).xpath("//input[@id = 'nb_item_bottom']/@value").text.to_i
  return (countOfProducts/25.00).ceil
end

def urlPage(url,page_n) # open html with select page
  load_url("#{url}?p=#{page_n.to_s}")
end

def getLinksFromPage(url_page) # gets links from select url
  url_page.xpath("//div[@class='product-desc display_sd']//a//@href").each do|link|
    puts link.content
  end
end
p countOfPages(select_url)
# getLinksFromPage(urlPage(select_url,1))
