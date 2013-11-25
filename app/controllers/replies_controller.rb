class RepliesController < ApplicationController

  before_action :set_scope, only: [:index, :new, :create]

  def index
  	@replies = @current_scope.replies
  end

  def new
    @reply = Reply.new
    @booking = @current_scope
  end

  def create
    @reply = @current_scope.replies.build(reply_params)
    @reply.sender = current_user
    @reply.recipient = @reply.sender == @current_scope.recipient ? @current_scope.sender : @current_scope.recipient
    
    respond_to do |format|
       if @reply.save
        format.html { redirect_to @current_scope, notice: 'Reply sent.' }
        # format.json { render action: 'show', status: :created, location: @booking.listing }
      else
        format.html { render action: 'new' }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  	# Find all replies for the parent booking
    def set_scope
    	if params[:booking_id]
      		@current_scope = Booking.find(params[:booking_id])
      	end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reply_params
      params.require(:reply).permit(:body)
    end
end
