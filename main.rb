require 'curb'
require 'nokogiri'
require 'csv'
require 'ruby-progressbar'
require_relative 'Modules/parser_container'
require_relative 'Models/parser'


if ARGV.length != 2
  puts "Wrong number of arguments(given #{ARGV.length}, expected 2) (ArgumentError)"
  exit
end

parser = Parser.new(ARGV[0])
parser.ResultOutput(ARGV[0],ARGV[1]);

