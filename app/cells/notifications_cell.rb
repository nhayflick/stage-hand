class NotificationsCell < Cell::Rails

  def index(args)
  	@user = args[:user]
  	@notifications = @user.notifications

    render
  end

end
