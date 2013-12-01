class User < ActiveRecord::Base
  acts_as_messageable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable                

  validates :username, length: { in: 3..30 }

  has_many :listings
  has_many :requested_bookings, through: :listings, source: :bookings
  has_many :bookings
end
