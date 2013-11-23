class Booking < ActiveRecord::Base
  validates :user, :listing, presence: :true

  belongs_to :listing
  belongs_to :user
  has_many :replies
end