class Booking < ActiveRecord::Base
  validates :sender, :listing, presence: :true

  belongs_to :listing
  belongs_to :sender, class_name: "User", foreign_key: "user_id"
  has_many :replies
  has_one :recipient, through: :listing, source: :user
end