class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :set_scope, only: :index

  # GET /bookings
  # GET /bookings.json
  def index
    @bookings = @current_scope.bookings
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
    @replies = @booking.replies
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @listing = Listing.find(params[:listing_id])
    # puts @listing.bookings
    @booking = @listing.bookings.build(booking_params)
    @booking.sender = current_user

    puts @booking.inspect
    respond_to do |format|
      if @booking.save!
        format.html { redirect_to @booking.listing, notice: 'Booking was successfully created.' }
        format.json { render action: 'show', status: :created, location: @booking.listing }
      else
        format.html { render action: 'new' }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    def set_scope
      if params[:listing_id]
        @current_scope = Listing.find(params[:listing_id])
      elsif params[:user_id]
        @current_scope = User.find(params[:user_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:sender, :recipient, :listing_id, :note, :start_date, :end_date, :accepted)
    end
end
