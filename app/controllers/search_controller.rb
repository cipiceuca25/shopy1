class SearchController < ApplicationController
  def do_the_search
    session['zoom_min'] = params[:zoom_min] if params[:zoom_min]
    session['zoom_max'] = params[:zoom_max] if params[:zoom_max]
    session['megapixels_min'] = params[:megapixels_min] if params[:megapixels_min]
    session['megapixels_max'] = params[:megapixels_max] if params[:megapixels_max]

    session['price_min'] = if params[:sort_by_price]
      session['price_min'] = PRICE_MIN
    elsif params[:price_min]
      params[:price_min]
    else
      session['price_min']  
    end

    session['price_max'] = if params[:sort_by_price]
      session['price_max'] = max_price
    elsif params[:price_max]
      params[:price_max]
    else
      session['price_max'] 
    end

    session['order'] = 'price DESC' if session['order'].blank?
    # Order Brand -----------------------------------------------------------------------------------
    sorting_brand
    # Filter ----------------------------------------------------------------------------------------
    filter_cameras
    # Sort ------------------------------------------------------------------------------------------
    sorting_cameras
    # Paginate --------------------------------------------------------------------------------------
    pagination

    render 'cameras/do_the_search', :layout => false
  end

  def do_sort_by_price
    session['order'] = if session['order'].eql?('price ASC')
      'price DESC'
    else
      'price ASC'
    end

    redirect_to '/do_the_search?sort_by_price=true'
  end

  def do_sort_by_megapixels
    if session['order'] == 'megapixels ASC'
      session['order'] = 'megapixels DESC'
    else
      session['order'] = 'megapixels ASC'
    end
    redirect_to '/do_the_search'
  end

  def do_sort_by_screen
    if session['order'] == 'screensize ASC'
      session['order'] = 'screensize DESC'
    else
      session['order'] = 'screensize ASC'
    end
    redirect_to '/do_the_search'
  end

  def do_sort_by_brand
    if session['order'] == 'brand_id ASC'
      session['order'] = 'brand_id DESC'
    else
      session['order'] = 'brand_id ASC'
    end
    redirect_to '/do_the_search'
  end

  def criteria_search
    # Session ---------------------------------------------------------------------------------------
    get_session
    @brands = Brand.order('name ASC')
    # Paginate --------------------------------------------------------------------------------------
    
    @search = params[:search]
    cameras = Camera.where("name ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    cameras = cameras.where('megapixels >= ? AND megapixels <= ?', session['megapixels_min'], session['megapixels_max'])
    cameras = cameras.where('price >= ? AND price <= ?', session['price_min'], session['price_max'])
    @cameras = cameras.where( 'zoom >= ? AND zoom <= ?', session['zoom_min'], session['zoom_max'] ).order("price DESC")
    @all_brands = @brands.map(&:id)
    @all_brands.each do |id|
      session['brands'].insert -1, "|#{id}"
    end

    pagination
    
    render "cameras/search"
  end

  def sorting_brand
    @brands = Brand.order('name ASC')
    if params[:brand] and !params[:brand].eql?('all')
      unless session['brands']
        session['brands'] = params[:brand]
      else
        brands = session['brands'].split('|')
        if brands.include? params[:brand]
          brands.delete params[:brand]
        else
          brands.insert -1, "|#{params[:brand]}"
        end
        session['brands'] = brands.split('|').uniq.sort*'|'
      end
    elsif params[:brand].eql?('all')
      brands = session['brands'].split('|')
      if brands.include? params[:brand]
        brands.delete 'all'
        all_brands = @brands.map(&:id)
        all_brands.each do |id|
          brands.insert -1, "|#{id}"
        end
      else
        brands = "all"
      end
      session['brands'] = brands.split('|').uniq.sort*'|'
    end
  end

  def filter_cameras
    cameras = Camera.where('megapixels >= ? AND megapixels <= ?', session['megapixels_min'], session['megapixels_max'])
    cameras = cameras.where('price >= ? AND price <= ?', session['price_min'], session['price_max'])
    @cameras = cameras.where('zoom >= ? AND zoom <= ?', session['zoom_min'], session['zoom_max'] ).order("price DESC")

    if session['brands'] and !session['brands'].eql?('all')
      cameras = cameras.where('zoom >= ? AND zoom <= ?', session['zoom_min'], session['zoom_max'])
      @cameras = Array.new
      session['brands'].split('|').each do |b|
        if !b.to_i.eql?(0)
          @cameras += cameras.where('brand_id = ?', b.to_i)
        end
      end
    elsif session['brands'].eql?('all')
      @cameras = Array.new
    else
      @cameras = Array.new
    end
  end

  def sorting_cameras
    case session['order']
    when 'price ASC'
      @cameras.sort! { |a,b| a.price <=> b.price }
    when 'price DESC'
      @cameras.sort! { |a,b| a.price <=> b.price }
      @cameras.reverse!
    when 'megapixels ASC'
      @cameras.sort! { |a,b| a.megapixels <=> b.megapixels }
    when 'megapixels DESC'
      @cameras.sort! { |a,b| a.megapixels <=> b.megapixels }
      @cameras.reverse!
    when 'screensize ASC'
      @cameras.sort! { |a,b| a.screensize <=> b.screensize }
    when 'screensize DESC'
      @cameras.sort! { |a,b| a.screensize <=> b.screensize }
      @cameras.reverse!
    when 'brand_id ASC'
      @cameras.sort! { |a,b| a.brand.name <=> b.brand.name }
    when 'brand_id DESC'
      @cameras.sort! { |a,b| a.brand.name <=> b.brand.name }
      @cameras.reverse!
    end
  end
end
