class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]              

  # before_validation :download_remote_image, :if => :avatar_url_provided?
  validates :name, length: { in: 3..30 }

  has_many :listings
  has_many :requested_bookings, through: :listings, source: :bookings
  has_many :bookings
  has_many :notifications, foreign_key: "recipient_id"

  # This method associates the attribute ":avatar" with a file attachment
  has_attached_file :avatar, styles: {
    thumb: '50x50#',
    square: '100x100#',
    medium: '300x300>'
  }

  process_in_background :avatar

  after_create :send_welcome_notification

  def self.with_nearby_listings
    joins(:listings).merge( Listing )
  end

  # -----------------------
  # Omniauth methods
  # -----------------------

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    puts auth.inspect
    unless user
      user = User.create(name:auth.extra.raw_info.name,
        provider:auth.provider,
        uid:auth.uid,
        email:auth.info.email,
        facebook_url:auth.info.image,
        password:Devise.friendly_token[0,20]
        )
    end
    user
  end

  # -----------------------
  # Geocoder methods
  # -----------------------

  geocoded_by :zipcode   # can also be an IP address
  after_validation :fetch_coordinates

  reverse_geocoded_by :latitude, :longitude do |obj,results|
	  if geo = results.first
	    state = geo.state
   		country_code = geo.country_code
    	obj.address = [geo.state, geo.country_code].join(",")
    	obj.city = geo.city
    	obj.state = geo.state
	  end
	end
  after_validation :reverse_geocode

  # -----------------------
  # Balanced Methods
  # -----------------------

  def balanced_customer
    return Balanced::Customer.find(self.customer_uri) if self.customer_uri

    begin
      customer = self.class.create_balanced_customer(
        :name   => self.name,
        :email  => self.email
        )
    rescue
      'There was an error fetching the Balanced customer'
    end

    self.customer_uri = customer.uri
    self.save
    customer
  end

  def self.create_balanced_customer(params = {})
    begin
      Balanced::Marketplace.mine.create_customer(
        :name   => params[:name],
        :email  => params[:email]
        )
    rescue
      'There was an error adding a customer'
    end
  end

  # -----------------------
  # Paperclip Methods
  # -----------------------

  def fetch_avatar
  	if self.avatar.url != '/avatars/original/missing.png'
  	  return self.avatar.url(:thumb) 
  	elsif self.facebook_url
  	  return self.facebook_url
    else
      'no url'
    end
  end

  private

  def send_welcome_notification
    self.notifications.create(title: 'Welcome to Scenius!', body: "Welcome to Scenius!", recipient_id: self.id)
  end

end
