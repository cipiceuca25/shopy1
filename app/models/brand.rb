class Brand < ActiveRecord::Base
  has_many :cameras

  def self.create_brand(brand)
    if brand.eql?("INTOVA")
      brand = brand.titleize
    end
    
    brand = Brand.find_or_create_by_name(brand)
    return brand
  end
end
