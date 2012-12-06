class CamerasController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  def search
   # Session ------------------------------------------------------------------------------------
    get_session
    cameras = Camera.where('megapixels >= ? AND megapixels <= ?', session['megapixels_min'], session['megapixels_max'])
    cameras = cameras.where('price >= ? AND price <= ?', session['price_min'], session['price_max'])
    @cameras = cameras.where( 'zoom >= ? AND zoom <= ?', session['zoom_min'], session['zoom_max'] ).order("price DESC")
    @brands = Brand.order('name ASC')
    @all_brands = @brands.map(&:id)
    @all_brands.each do |id|
      session['brands'].insert -1, "|#{id}"
    end
    # Paginate --------------------------------------------------------------------------------------
    pagination
  end

  def index
    @cameras = Camera.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @cameras }
    end
  end

  def show
    @camera = Camera.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @camera }
    end
  end

  def new
    @camera = Camera.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @camera }
    end
  end

  def edit
    @camera = Camera.find(params[:id])
  end

  def create
    @camera = Camera.new(params[:camera])

    respond_to do |format|
      if @camera.save
        format.html { redirect_to(@camera, :notice => 'Camera was successfully created.') }
        format.xml { render :xml => @camera, :status => :created, :location => @camera }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @camera.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @camera = Camera.find(params[:id])

    respond_to do |format|
      if @camera.update_attributes(params[:camera])
        format.html { redirect_to(@camera, :notice => 'Camera was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @camera.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @camera = Camera.find(params[:id])
    @camera.destroy

    respond_to do |format|
      format.html { redirect_to(cameras_url) }
      format.xml { head :ok }
    end
  end
end
