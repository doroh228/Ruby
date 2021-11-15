class Product
  attr_accessor :name, :price, :image

  def initialize(name, price, image)
    @name, @price, @image = name, price, image
  end
end