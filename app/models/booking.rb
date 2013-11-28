class Booking < ActiveRecord::Base
  validates :sender, :listing, presence: :true
  validate :no_overlaps, on: :create

  belongs_to :listing
  belongs_to :sender, class_name: "User", foreign_key: "user_id"
  has_many :replies
  has_one :recipient, through: :listing, source: :user

  def no_overlaps
  	errors.add(:base, "This listing is already booked for those dates! Please try adjusting your rental dates.") if self.overlapping?
  end

  def overlapping?
  	self.listing.bookings.each do |other_booking|
  		if (self.start_date..self.end_date).overlaps?(other_booking.start_date..other_booking.end_date)
  			return true
  		end
  	end
  	return false
  end

end