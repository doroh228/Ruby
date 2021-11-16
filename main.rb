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

=begin
class Apple
  attr_accessor :name, :weight, :color

  def initialize (name, weight, color)
    @name, @weight, @color = name, weight, color
  end
end
CSV.open(ARGV[1], "w", :write_headers=> true, :headers => ["Name","Weight","Color"]) {}
apples = []

(0..10).each do |i|
  someApple = Apple.new("name"+i.to_s, (i*rand(10)).to_s + " g", "color"+i.to_s)
  apples << someApple
end


CSV.open(ARGV[1], "a") do |csv|
  apples.each { |apple|
    csv << [apple.name, apple.weight, apple.color]
  }
end
=end

