require 'curb'
require 'nokogiri'
require 'csv'
require 'ruby-progressbar'
require_relative '../Modules/parser_container'
require_relative 'product'


class Parser
  attr_accessor :main_html
  include ParserContainer

  def initialize (url)
    @main_html = load_url(url)
  end

  def ResultOutput(url_Category, name_Csv_File)
    total_items = 0
    links = getAllLinksOnProducts(url_Category)
    progressbar = ProgressBar.create(title: "Grabbed", format: "%t %c/%C products: |%b>%i| %E", total: links.length)

    CSV.open(name_Csv_File, "w", :write_headers=> true, :headers => ["Name","Price","Image"]) {}

    threads = []
    links.each do |link|
      threads << Thread.new do
        result = getDataAboutProduct(link)
        CSV.open(name_Csv_File, "a",) do |csv|
          result.each do |p|
            csv << [p.name, p.price, p.image]
          end
        end
        total_items += result.length
        progressbar.increment
      end
    end
    threads.map(&:join)
    puts "Grabbed #{total_items} items from #{links.length} product pages"
  end
end