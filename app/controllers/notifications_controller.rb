class NotificationsController < ApplicationController

	after_action :save_as_viewed

	def index
	  	@notifications = current_user.notifications

	  	respond_to do |format|
		  	format.html  do
		      if request.xhr?
		        render :partial => 'index'
		      else
		        redirect_to home_index_path
		      end
		    end
		end
	end

	def render_bell
	  	@notifications = current_user.notifications

	  	respond_to do |format|
		  	format.html  do
		      if request.xhr?
		        render :partial => '/layouts/notifications_bell'
		      else
		        redirect_to home_index_path
		      end
		    end
		end
	end

	private

	def save_as_viewed
		@notifications.each do |notification|
			unless notification.viewed
				notification.update_attribute(:viewed, true)
				notification.save!
			end
		end
	end
end
