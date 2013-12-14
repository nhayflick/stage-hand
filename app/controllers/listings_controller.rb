class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :is_owner?, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create]
  before_action :check_wepay, only: [:new, :create]
  # GET /listings
  # GET /listings.json
  def index
    @q = Listing.search(params[:q])
    if params[:zipcode] && params[:category]
      @listings = Listing.joins(:user).near(params[:zipcode], 50).where(:category => params[:category]).includes(:listing_images)
    elsif params[:zipcode]
       @listings = Listing.joins(:user).near(params[:zipcode], 50)
    elsif params[:category]
      @listings = Listing.where(:category => params[:category])
    else
      @listings = Listing.all
    end
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
    if current_user && @listing.user != current_user
      if current_user.bookings.where(listing_id: @listing.id).exists?
        @booking = current_user.bookings.find_by! listing_id: @listing.id
      else
        @booking = @listing.bookings.build
      end
    end
  end

  # GET /listings/new
  def new
    @listing = Listing.new
    3.times {@listing.listing_images.build}
  end

  # GET /listings/1/edit
  def edit
    3.times {@listing.listing_images.build}
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)
    @listing.user = current_user

    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render action: 'show', status: :created, location: @listing }
      else
        3.times {@listing.listing_images.build}
        format.html { render action: 'new' }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    def search_listings
      if params[:zipcode] || params[:category]

        @listings
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:user_id, :category, :name, :rate, :description, listing_images_attributes: [:listing_id, :image])
    end

    def is_owner?
      if current_user != @listing.user
        redirect_to root_path
        return false
      else
        return true
      end
    end

    def check_wepay
      if !current_user.has_valid_wepay_access_token? || !current_user.has_wepay_account?
        redirect_uri = url_for(:controller => 'users', :action => 'oauth', :user_id => @current_user.id, :host => request.host_with_port)
        redirect_to current_user.wepay_authorization_url(redirect_uri)
      end
    end
end
