class RepliesController < ApplicationController

  before_action :set_scope, only: [:index]

  def index
  	@replies = @current_scope.replies
  end

  def create
  	@reply = @current_scope.bookings.new(:reply_parameters).user = current_user

  
  end

  private

  	# Find all replies for the parent booking
    def set_scope
    	if params[:booking_id]
      		@current_scope = Booking.find(params[:booking_id])
      	end
    end
end
