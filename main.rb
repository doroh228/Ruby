require 'curb'
require 'nokogiri'
require 'csv'
require 'open-uri'
#require_relative ''

select_url ='https://www.petsonic.com/farmacia-para-gatos/'

def load_url(url)
  return Nokogiri::HTML(URI.open(url))
end

def countOfPages (url) # How many pages on this page #TODO: create new method, more faster than this
  source_HTML = load_url(url) #HTML code of page
  contentWithCountOfProducts = "" # String with count of all products in this
  source_HTML.xpath("//div[@class='product-count hidden-xs']").each do |link| # Search div with data about count of pages
    contentWithCountOfProducts = link.content # Into content we have count of pages & this last number in this str
  end
  x = []; # Array for intermediate numbers
  y = []; # Array for done numbers
  finalIntermediateNumber = "" # Final intermediate number
  for i in (0..contentWithCountOfProducts.length)
    if contentWithCountOfProducts[i] =="0" # Check on 0, coz method 'to_i' return 0 if isChar
      x<<contentWithCountOfProducts[i].to_i # Write in array while 'contentWithCountOfProducts[i].isNumber ==true'
    elsif (contentWithCountOfProducts[i].to_i != 0) # Check on 0, coz method 'to_i' return 0 if isChar
      x << contentWithCountOfProducts[i].to_i # Write in array while 'contentWithCountOfProducts[i].isNumber ==true'
    else
      if x.length>0 # Array x was filled numbers
        for i1 in (0...x.length)
          finalIntermediateNumber+="#{x[i1]}" # Write in str all number in x(array)
        end
        if finalIntermediateNumber !=""
          y<<finalIntermediateNumber # Add final number in array
          finalIntermediateNumber = "" # clearing final number and search new number
          x = [] #clearing array and search new numbers
        end
      end
    end
  end
  return (y[-1].to_i/25.00).ceil # return count of pages on url(https://www.petsonic.com/farmacia-para-gatos/), coz I'm searched by css style(class = 'product-count hidden-xs')
                                 # last number in 'contentWithCountOfProducts' it's count of products
                                 # one page have 25 products
                                 # rounding up
end

def urlPage(url,page_n) # open html with select page
  load_url("#{url}?p=#{page_n.to_s}")
end

def getLinksFromPage(url_page) # gets links from select url
  url_page.xpath("//div[@class='product-desc display_sd']//a//@href").each do|link|
    puts link.content
  end
end

getLinksFromPage(urlPage(select_url,1))
