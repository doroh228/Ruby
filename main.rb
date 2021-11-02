require 'curb'
require 'nokogiri'
require 'csv'
require 'open-uri'
#require_relative ''

Select_url ='https://www.petsonic.com/farmacia-para-gatos/'

def load_url(url)
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
  for i in (1..countOfPages(Select_url))
    url_selectPage = urlPage(Select_url,i)
    links+=getLinksFromPage(url_selectPage)
  end
  return links
end
p countOfPages(Select_url)
p getsAllLinksOnProduts.length
