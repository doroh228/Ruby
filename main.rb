require 'curb'
require 'nokogiri'
require 'csv'
require 'ruby-progressbar'
require_relative 'Modules/parser_container'
require_relative 'Models/parser'
require 'yaml'


params = YAML.load_file('params.yml')

parser = Parser.new(params['category'])
parser.ResultOutput(params['category'],params['file'])


