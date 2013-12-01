class Booking < ActiveRecord::Base
  validates :sender, :listing, presence: :true
  validate :no_overlaps, on: :create

  belongs_to :listing
  belongs_to :sender, class_name: "User", foreign_key: "user_id"
  has_many :replies
  has_one :recipient, through: :listing, source: :user

  after_create :send_request_notification

  state_machine :initial => :requested do

    event :accept do
      transition :requested => :accepted
    end

    before_transition :requested => :accepted, :do => :record_acceptance
    after_transition :requested => :accepted, :do => :send_accepted_notification
  end

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

  def self.related_to_user(user)
  	(user.requested_bookings + user.bookings).sort{|a,b| a.created_at <=> b.created_at }
  end

  def send_request_notification
    puts "notification callback"
    self.recipient.notify(
      'New Booking!',
      '#{booking.sender.username.capitalize} sent a request for #{booking.listing.name})!',
    self.listing)
  end

  def send_accepted_notification(booking)
    self.sender.notify(
      'Booking accepted!',
      '#{booking.recipient.username.capitalize} accepted your booking request for #{booking.listing.name})! Enter your payment info to confirm your reservation!',
      self)
  end

  def record_acceptance
    self.update_attribute('accepted_at', DateTime.now)
  end

end