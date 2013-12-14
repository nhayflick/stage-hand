class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy, :pay, :payment_success]
  before_action :detect_change_state, only: :update
  before_action :set_scope, only: :index

  # GET /bookings
  # GET /bookings.json
  def index
    @bookings = @current_scope
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
    @booking = Booking.new(booking_params)
    @booking.sender = current_user
    @booking.listing_id = params[:listing_id]

    respond_to do |format|
      if @booking.save
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

  # GET /bookings/pay/1
  def pay
    redirect_uri = url_for(:controller => 'bookings', :action => 'payment_success', :id => params[:id], :host => request.host_with_port)
    begin
      @checkout = @booking.create_checkout(redirect_uri)
    rescue Exception => e
      redirect_to @booking, alert: e.message
    end
  end

  # GET /bookings/payment_success/1
  def payment_success
    if !params[:checkout_id]
      return redirect_to @booking, alert: "Error - Checkout ID is expected"
    end
    if (params['error'] && params['error_description'])
      return redirect_to @booking, alert: "Error - #{params['error_description']}"
    end
    @booking.collect_payment
    redirect_to @booking, notice: "Your payment info was recieved! You should receive a confirmation email shortly."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    def set_scope
      if params[:listing_id]
        @current_scope = Listing.find(params[:listing_id]).bookings
      elsif params[:user_id]
        @current_scope = Booking.related_to_user(User.find(params[:user_id]))
      elsif current_user
        @current_scope = Booking.related_to_user(current_user)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:note, :start_date, :end_date)
    end

    def detect_change_state
      puts "detecting"
      case params[:booking][:state]
          when 'accept'
            @booking.accept
            puts 'accept'
            redirect_to @booking, notice: 'Booking was accepted!'
            return false
          when 'cancel'
            @booking.cancel
            puts 'cancel'
            return false
          else
            puts 'no state'
            return true
      end
    end
end
