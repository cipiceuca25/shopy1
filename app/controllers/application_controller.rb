class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :init_menus

  def init_menus
    @main_menu = Array.new

    if current_user
      unless user_signed_in?
        @main_menu << {:path => '/', :text => 'home'}
        @main_menu << {:path => new_user_registration_path, :text => 'register'}
      else
        @main_menu << {:path => root_path, :text => 'home'}
        @main_menu << {:path => user_registration_path, :text => 'manage users'} if current_user.is_admin
        @main_menu << {:path => edit_user_registration_path, :text => 'profile'}
        @main_menu << {:path => destroy_user_session_path, :text => 'logout'}
      end
    else
      @main_menu << {:path => '/', :text => 'home'}
      @main_menu << {:path => new_user_registration_path, :text => 'register'}
      @main_menu << {:path => new_user_session_path, :text => 'login'}
    end
  end

  def max_price
    Camera.calculate_price(Camera.maximum('price').to_s).to_i
  end

  def max_zoom
    Camera.calculate_price(Camera.maximum('zoom').to_s).to_i
  end

  def max_megapixel
    Camera.calculate_price(Camera.maximum('megapixels').to_s).to_i
  end

  def get_session
    session['zoom_min'] = ZOOM_MIN
    session['zoom_max'] = max_zoom
    session['megapixels_min'] = MEGAPIXELS_MIN
    session['megapixels_max'] = max_megapixel
    session['price_min'] = PRICE_MIN
    session['price_max'] = max_price
    session['brands'] = ''
  end
  
  def pagination
    if params[:page]
      page = params[:page].to_i - 1
    else
      page = 0
    end
    
    @total_camera = @cameras.count
    if @cameras.count > PER_PAGE
      start_cam = page.to_i * PER_PAGE
      end_cam = ((page.to_i * PER_PAGE) + PER_PAGE) > @cameras.count ? @cameras.count : ((page.to_i * PER_PAGE) + PER_PAGE)
      if (@cameras.count / PER_PAGE) < (@cameras.count / PER_PAGE.to_f)
        @total_pages = ((@cameras.count / PER_PAGE).to_i + 1)
      else
        @total_pages = (@cameras.count / PER_PAGE).to_i
      end
      @cameras = @cameras[start_cam...end_cam]
      @page = page + 1
    else
      @total_pages = 0
    end
    @results = @cameras.count
  end
  # Private methods ==================================================================================
  private
  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
