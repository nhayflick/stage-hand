class NotificationsCell < Cell::Rails

  def index(args)
  	@user = args[:user]
  	@notifications = @user.notifications

  	respond_to do |format|
	  	format.html  do
	      if request.xhr?
	        render
	      else
	        render
	      end
	    end
	end
  end

end