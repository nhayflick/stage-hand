class HomeController < ApplicationController
  def index
    if Rails.env.production? && !current_user
      flash.now[:notice] = "Thanks for checking out Scenius - the first peer-to-peer marketplace for musicians to rent out unused instruments! You can search, request instrument rentals or list one of your own instruments. Feel free to login with the following credentials if you don't feel like creating an account yet: Username: test@test.com, Password: foobar123."
    end
  end
end
