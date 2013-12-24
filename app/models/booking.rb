class Booking < ActiveRecord::Base

  attr_readonly :user_id, :listing_id, :note, :start_date, :end_date, :paid_at, :canceled_at, :debit_uri, :credit_uri, :price, :deposit_price

  def self.add_scenius_fee(price)
    1.15 * price
  end

  validates :sender, :listing, presence: :true
  validate :no_overlaps, :valid_dates, :valid_card, on: :create

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
      transition :accepted => :paid
    end

    event :deny_transaction do
      transition :accepted => :denied
    end

    event :deny do
      transition [:requested, :accepted] => :denied
    end

    event :cancel do
      transition [:requested, :accepted, :paid] => :cancel
    end

    event :start do
      transition :paid => :started
    end

    event :credit do
      transition :started => :credited
    end

    event :settle do
      transition :credited => :completed
    end

    after_transition :requested => :accepted, :do => :record_acceptance
    after_transition :requested => :accepted, :do => :send_accepted_notification
    after_transition :requested => :accepted, :do => :transact
    after_transition :accepted => :paid, :do => :record_payment
    after_transition :accepted => :paid, :do => :send_payment_notification
    after_transition :accepted => :paid, :do => :schedule_booking

    # around_transition on: :accept do |booking, transition, block|
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
    errors.add(:base, "Your rental must last for at least one day.") if self.start_date > self.end_date
    errors.add(:base, "No time-traveling allowed - please check your rental dates.") if self.start_date < Date.current
  end

  def valid_card
    errors.add(:credit_uri, "must be valid") unless self.credit_uri
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
    BookingMailer.delay.booking_remind_owner_email(self)
    BookingMailer.delay.booking_remind_renter_email(self)
  end

  def send_booking_completed_email
    BookingMailer.delay.booking_completed_email(self)
  end
  
  def send_payment_failed_email
    BookingMailer.delay.booking_payment_failed_email(self)
  end

  def schedule_booking
    BookingMailer.delay.booking_remind_owner_email(self)
  end
  # handle_asynchronously :cancel_if_not_paid, :run_at => Proc.new { 1.day.from_now }



  # ------------------------------
  # Controller Methods
  # ------------------------------

  def self.related_to_user(user)
  	(user.requested_bookings + user.bookings).sort{|a,b| a.created_at <=> b.created_at }
  end

  def calculate_price
    length = self.end_date - self.start_date
    price = Booking.add_scenius_fee((length * self.listing.rate + self.listing.deposit_price) * 100)
    self.price = price
    self.deposit_price = self.listing.deposit_price
  end

  # ------------------------------
  # Notification Methods
  # ------------------------------

  def send_request_notification
    self.notifications.create(title: 'New Booking!', body: "#{self.sender.name.capitalize} sent a request for #{self.listing.name}", recipient_id: self.recipient.id)
    self.send_new_booking_email
  end

  def send_accepted_notification(booking)
    self.notifications.create(title: 'Booking Accepted!', body: "#{self.recipient.name.capitalize} accepted your booking request for #{self.listing.name}. Your payment has been processed in order to hold your booking reservation.", recipient_id: self.sender.id)
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
  # Balanced Methods
  # ------------------------------

  def transact
    renter = self.sender.balanced_customer
    owner = self.recipient.balanced_customer
    
    if !renter.add_card(self.credit_uri)
       # raise "Error - Card failed."
       return self.transaction_failed
    end

    # debit buyer amount of listing

    debit = renter.debit(
        :amount => self.price,
        :description => "Scenius Rental (#{self.start_date.to_formatted_s} to #{self.end_date.to_formatted_s}) #{self.listing.name} from #{self.recipient.name}",
        :on_behalf_of => owner,
    )

    if !debit
      # raise "Error - Debit failed."
      return self.transaction_failed
    end

    self.debit_uri = debit.uri
    self.save

    # # credit owner of bicycle amount of listing

    # credit = owner.credit(
    #   :amount => 100,
    #   :description => "Scenius Rental (#{self.start_date.to_formatted_s} to #{self.end_date.to_formatted_s}) #{self.listing.name} from #{self.sender.name}",
    # )

    # if !credit
    #   raise "Error - Credit failed."
    # end

    self.collect_payment
  end

  def transaction_failed
    self.notifications.create(title: 'Transaction Failed!', body: "This booking has been canceled automatically because the payment from #{self.sender.name.capitalize} failed!", recipient_id: self.recipient.id)
    self.notifications.create(title: 'Transaction Failed!', body: "This booking has been canceled automatically because your payment to #{self.recipient.name.capitalize} failed! Please make sure you are using a valid credit card and try again.", recipient_id: self.recipient.id)
    self.send_payment_failed_email
    self.deny_transaction
  end

  def pay_owner
    credit = owner.credit(
      :amount => self.price,
      :description => "Scenius Rental (#{self.start_date.to_formatted_s} to #{self.end_date.to_formatted_s}) #{self.listing.name} from #{self.sender.name}",
    )

    if !credit
      raise "Error - Credit failed."
    end
  end

  def settle_deposit
    debit = Balanced::Debit.find(self.debit_uri)
    debit.refund(
      :amount => self.deposit_price,
      :description => 'Scenius Damage Deposit Refund'
    )
  end

end