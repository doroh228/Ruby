require 'curb'
require 'nokogiri'
require 'csv'
require 'ruby-progressbar'
require_relative '../Modules/parser_container'
require_relative 'product'
require 'yaml'

class Parser
  attr_accessor :main_html, :progressbar, :total_items, :params
  include ParserContainer

  def initialize (url)
    load_yaml_params
    @main_html = load_url(url)
  end

  def ResultOutput(url_Category, name_Csv_File)
    @total_items = 0
    links = getAllLinksOnProducts(url_Category)
    @progressbar = ProgressBar.create(title: "Grabbed", format: "%t %c/%C products: |%b>%i| %E", total: links.length)
    CSV.open(name_Csv_File, "w", :write_headers=> true, :headers => ["Name","Price","Image"]) {}
    threads = GetAllThreadsForWritingToFile(links, name_Csv_File)
    threads.map(&:join)
    puts "Grabbed #{total_items} items from #{links.length} product pages"
  end



end