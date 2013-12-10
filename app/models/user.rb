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

  after_create :send_welcome_notification

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
  # after_validation :geocode



  # -----------------------
  # Wepay Methods
  # -----------------------

  # returns a url
	def wepay_authorization_url(redirect_uri)
	  WEPAY.oauth2_authorize_url(redirect_uri, self.email, self.name)
	end

	def has_wepay_access_token?
	  !self.wepay_access_token.nil?
	end

	# makes an api call to WePay to check if current access token for user is still valid
	def has_valid_wepay_access_token?
	  if self.wepay_access_token.nil?
	    return false
	  end
	  response = WEPAY.call("/user", self.wepay_access_token)
	  response && response["user_id"] ? true : false
	end

	# takes a code returned by wepay oauth2 authorization and makes an api call to generate oauth2 token for this user.
	def request_wepay_access_token(code, redirect_uri)
	  response = WEPAY.oauth2_token(code, redirect_uri)
	  if response['error']
	    raise "Error - "+ response['error_description']
	  elsif !response['access_token']
	    raise "Error requesting access from WePay"
	  else
	    self.wepay_access_token = response['access_token']
	    self.save

		#create WePay account
	    self.create_wepay_account
	  end
	end


	def has_wepay_account?
	  self.wepay_account_id != 0 && !self.wepay_account_id.nil?
	end

	# creates a WePay account for this user with the user's name
	def create_wepay_account
	  if self.has_wepay_access_token? && !self.has_wepay_account?
	    params = { :name => self.name, :description => "Scenius member." }			
	    response = WEPAY.call("/account/create", self.wepay_access_token, params)

	    if response["account_id"]
	      self.wepay_account_id = response["account_id"]
	      return self.save
	    else
	      raise "Error - " + response["error_description"]
	    end

	  end		
	  raise "Error - cannot create WePay account"
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
