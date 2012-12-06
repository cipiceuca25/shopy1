require 'aws/s3'
require 'amazon/ecs'

class Camera < ActiveRecord::Base
  APP_NAME = 'sortgadget'
  BUCKET_NAME = 'SortGadgetTest'

  ACCESS_KEY = 'AKIAJP7RCDHLQGNNWNLA'
  SECRET = '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'
  #ASSOCIATE_TAG = 'sortgadget-20'

  #Amazon::Ecs.options = {:associate_tag => 'sortgadget-20', :AWS_access_key_id => '14X6HZ46RQN2ZF3MC6G2', :AWS_secret_key => 'sFb1awZ5M9YjAPH0K97+rqaW0so1seId5At+Ne3B'}
  belongs_to :brand

  # will paginate
  cattr_reader :per_page
  @@per_page = 20

  def self.searching_camera(name=nil)
    initialize_amazon
    name = name || 'sony'
    res = Amazon::Ecs.item_search(name, {:response_group => 'Large', :search_index => 'Photo'})
    array_camera = []
    res.items.each do |camera|
      zoom = camera.get('ItemAttributes/OpticalZoom')
      megapixel = camera.get('ItemAttributes/MaximumResolution')
      if !zoom.to_i.eql?(0) or !megapixel.to_i.eql?(0)
        brand = camera.get('ItemAttributes/Brand')
        new_brand = Brand.create_brand(brand)
        name = camera.get('ItemAttributes/Title')
        description = camera.get('EditorialReviews/EditorialReview/Content')
        price = camera.get('Offers/Offer/OfferListing/Price/FormattedPrice')
        screensize = camera.get('ItemAttributes/DisplaySize') || camera.get('ItemAttributes/MonitorSize')
        original_extension = camera.get('MediumImage/URL') || camera.get('ImageSets/ImageSet/MediumImage/URL')
        page_url = camera.get('DetailPageURL')
        asin = camera.get('ASIN')
        array_camera << insert_camera_to_database(name, description, megapixel, price, zoom, screensize, new_brand.id, original_extension, page_url, asin)
      end
    end
    return array_camera
  end

  def self.get_cameras_from_amazon
    brands = %w{B&W sony canon casio fuji fujifilm GE kodak nikon intova jazz leica olympus panasonic samsung pentax vivitar vivicam}
    for brand in brands
      brand = if brand.downcase.eql?("intova")
        brand.downcase
      else
        brand
      end
      
      searching_camera(brand)
    end
  end

  def self.get_zoom(name)
    array = name.split(' ')
    1.upto(7) do |i|
      if array.index('Zoom')
        if array[array.index('Zoom') - i].include?('x')
          if array[array.index('Zoom') - i].gsub('x','').to_f.eql?(0.0)
            n = i + 1
            return array[array.index('Zoom') - n].gsub('x','').to_f
          else
            return array[array.index('Zoom') - i].gsub('x','').to_f
          end
        end
      elsif array.index('zoom')
        if array[array.index('zoom') - i].include?('x')
          if array[array.index('zoom') - i].gsub('x','').to_f.eql?(0.0)
            n = i + 1
            return array[array.index('zoom') - n].gsub('x','').to_f
          else
            return array[array.index('zoom') - i].gsub('x','').to_f
          end
        end
      end
    end
  end

  def self.update_zoom_mp
    cameras = Camera.where('megapixels = 0.0 OR zoom = 0.0')
    cameras.each do |camera|
      if camera.zoom.to_f.eql?(0.0)
        camera.zoom = get_zoom(camera.name)
        camera.save
      elsif camera.megapixels.to_f.eql?(0.0)
        camera.megapixels = get_megapixel(camera.name)
        camera.save
      else
        camera.zoom = get_zoom(camera.name)
        camera.megapixels = get_megapixel(camera.name)
        camera.save
      end
    end
  end

  def self.get_megapixel(name)
    array = name.split(' ')
    if array.index('MP')
      if !array[array.index('MP') - 1].to_f.eql?(0.0)
        return array[array.index('MP') - 1]
      else
        array.each do |mp|
          if mp.include?("MP")
            if !mp.gsub('MP', '').to_f.eql?(0.0)
              return mp.gsub('MP', '').to_f
            end
          elsif mp.include?("mp")
            if !mp.gsub('mp', '').to_f.eql?(0.0)
              return mp.gsub('mp', '').to_f
            end
          end
        end
      end
    elsif array.index('Megapixel')
      if !array[array.index('Megapixel') - 1].to_f.eql?(0.0)
        return array[array.index('Megapixel') - 1]
      else
        array.each do |mp|
          if mp.include?("Megapixel")
            if !mp.gsub('Megapixel', '').to_f.eql?(0.0)
              return mp.gsub('Megapixel', '').to_f
            end
          elsif mp.include?("megapixel")
            if !mp.gsub('megapixel', '').to_f.eql?(0.0)
              return mp.gsub('megapixel', '').to_f
            end
          end
        end
      end
    end

  end
  
  def self.insert_camera_to_database(name, description, megapixel, price, zoom, screensize, brand_id, original_extension, page_url, asin)
    camera = Camera.find_or_create_by_asin(asin)
    camera.name = name
    camera.description = description
    if megapixel.to_f.eql?(0.0)
      camera.megapixels = get_megapixel(name)
    else
      camera.megapixels = megapixel.to_f
    end
    if zoom.to_f.eql?(0.0)
      camera.zoom = get_zoom(name)
    else
      camera.zoom = zoom.to_f
    end
    camera.price = calculate_price(price)
    camera.screensize = screensize.to_f
    camera.brand_id = brand_id.to_i
    camera.original_extension = original_extension
    camera.asin = asin
    camera.page_url = page_url
    camera.save
    return camera
  end

  def self.calculate_price(price)
    if !price.nil?
      price1 = price.gsub('$','').to_f.ceil.to_s
      if price1.last.to_i.eql?(0)
        return price1.to_f
      else
        price = 10 - price1.last.to_i
        return price1.to_f + price.to_f
      end
    else
      return 0.to_f
    end
  end

  def self.update_price
    cameras = Camera.all
    cameras.each do |camera|
      camera.price = calculate_price(camera.price.to_s)
      camera.save
    end
  end

  def self.initialize_amazon
    Amazon::Ecs.options = {:associate_tag => BUCKET_NAME, :AWS_access_key_id => ACCESS_KEY, :AWS_secret_key => SECRET}
  end

  def after_save
    store_image if self.has_image?
  end

  def url_to_s3
    AWS::S3::Base.establish_connection!(
      :access_key_id => ACCESS_KEY,
      :secret_access_key => SECRET
    )
    AWS::S3::S3Object.url_for(self.image_filename, BUCKET_NAME, :expires_in => 1.day)
  end

  # file save routines ---------------------------------------------------------------------
  def string_filename
    "#{self.id.to_s}#{self.created_at.strftime("%d%m%y")}"
  end

  def image_filename
    File.join "#{Digest::MD5.hexdigest self.string_filename}.#{self.original_extension or 'jpg'}"
  end

  def image=(file_data)
    unless file_data.blank?
      @file_data = file_data
      self.original_extension = file_data.original_filename.split('.').last.downcase rescue 'jpg'
    end
  end

  def has_image?
    !(self.original_extension.nil?)
  end

  def store_image
    if @file_data
      File.open(image_filename, 'wb') do |f|
        f.write(@file_data.read)
      end
      @file_data = nil

      # upload to S3
      AWS::S3::Base.establish_connection!(
        :access_key_id => ACCESS_KEY,
        :secret_access_key => SECRET
      )

      begin
        bucket = AWS::S3::Bucket.find(BUCKET_NAME)
      rescue AWS::S3::NoSuchBucket
        AWS::S3::Bucket.create(BUCKET_NAME)
        bucket = AWS::S3::Bucket.find(BUCKET_NAME)
      end

      AWS::S3::S3Object.store(self.image_filename, File.open(image_filename, "r"), bucket.name, :access => :public_read)
      File.delete image_filename
    end
  end

  private :store_image

end


