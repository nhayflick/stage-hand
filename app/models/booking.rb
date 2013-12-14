class Booking < ActiveRecord::Base
  validates :sender, :listing, presence: :true
  validate :no_overlaps, :valid_dates, on: :create

  belongs_to :listing
  belongs_to :sender, class_name: "User", foreign_key: "user_id"
  has_many :replies
  has_one :recipient, through: :listing, source: :user
  has_many :notifications, as: :notifiable

  after_create :send_request_notification

  # ------------------------------
  # State Machine 
  # ------------------------------

  state_machine :initial => :requested do

    event :accept do
      transition :requested => :accepted
    end

    event :collect_payment do
      transition :accepted => :payment_collected
    end

    event :deny do
      transition [:requested, :accepted] => :denied
    end

    event :start do
      transition :paid => :canceled
    end

    after_transition :requested => :accepted, :do => :record_acceptance
    after_transition :requested => :accepted, :do => :send_accepted_notification
    after_transition :accepted => :payment_collected, :do => :record_payment
    after_transition :accepted => :payment_collected, :do => :send_payment_notification

    # around_transition on: :collect_payment do |booking, transition, block|
    #   booking.transition do
    #     block.call # block is an event's proc. we need to perform it
    #     booking.pay_author!
    #   end
    # end
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

  def valid_dates
    errors.add(:base, "Your rental must last for at least one full day.") if self.start_date >= self.end_date
  end

  # ------------------------------
  # Delayed_Jobs
  # ------------------------------

  def send_new_booking_email
    BookingMailer.delay.booking_requested_email(self)
  end

  def send_booking_accepted_email
    BookingMailer.delay.booking_accepted_email(self)
  end

  def send_booking_canceled_email
    BookingMailer.delay.booking_canceled_email(self)
  end

  def send_booking_reminder_email
    BookingMailer.delay.booking_reminder_email(self)
  end

  def send_booking_completed_email
    BookingMailer.delay.booking_completed_email(self)
  end
  
  def cancel_if_not_paid
    if (self.state == 'accepted')
      self.cancel
      BookingMailer.delay.booking_unpaid_and_canceled_email(self)
    end
  end
  handle_asynchronously :cancel_if_not_paid, :run_at => Proc.new { 1.day.from_now }



  # ------------------------------
  # Controller Methods
  # ------------------------------

  def self.related_to_user(user)
  	(user.requested_bookings + user.bookings).sort{|a,b| a.created_at <=> b.created_at }
  end

  # ------------------------------
  # Notification Methods
  # ------------------------------

  def send_request_notification
    self.notifications.create(title: 'New Booking!', body: "#{self.sender.name.capitalize} sent a request for #{self.listing.name}", recipient_id: self.recipient.id)
    self.send_new_booking_email
  end

  def send_accepted_notification(booking)
    self.notifications.create(title: 'Booking Accepted!', body: "#{self.recipient.name.capitalize} accepted your booking request for #{self.listing.name}. Enter your payment info to confirm your reservation!", recipient_id: self.sender.id)
  end

  def send_payment_notification(booking)
    self.notifications.create(title: 'Booking Payment Completed!', body: "#{self.sender.name.capitalize} approved a payment for #{self.listing.name}. Funds will be deposited 24 hours after equipment rental!", recipient_id: self.recipient.id)
  end

  # ------------------------------
  # Update Attribute Methods
  # ------------------------------

  def record_acceptance
    self.update_attribute('accepted_at', DateTime.now)
  end

  def record_payment
    self.update_attribute('paid_at', DateTime.now)
  end

  # ------------------------------
  # Wepay Methods
  # ------------------------------

  def create_checkout(redirect_uri)
    duration = (self.end_date - self.start_date).to_i
    total_cost = self.listing.rate.to_i * duration

    # calculate app_fee as 15% of produce price
    app_fee = total_cost * 0.15

    params = { 
      :account_id => self.recipient.wepay_account_id, 
      :short_description => "Scenius equipment rental of #{self.listing.name} from #{self.start_date} to #{self.end_date}.",
      :type => :SERVICE,
      :amount => total_cost,      
      :app_fee => app_fee,
      :fee_payer => :payee,     
      :mode => :iframe,
      :redirect_uri => redirect_uri
    }
    response = WEPAY.call('/checkout/create', self.recipient.wepay_access_token, params)

    if !response
      raise "Error - no response from WePay"
    elsif response['error']
      raise "Error - " + response["error_description"]
    end

    return response
  end

end