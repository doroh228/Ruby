
class Product
  attr_accessor :name, :price, :image

  def initialize(name, price, image)
    @name, @price, @image = name, price, image
  end

  def save(name_file)
    CSV.open(name_file, "a") { |csv| csv << [@name, @price, @image]}
  end
end