class BookingConcierge
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options :queue => :default

  recurrence { daily }

  recurrence backfill: true do
    hourly
  end

  def perform(last_occurrence, current_occurrence)
    Booking.where(start_date: Date.today, state: 'payment_collected').each do |booking|
        booking.send_booking_reminder_email
    end
    Booking.where(start_date: 2.days.ago, state: 'started').each do |booking|
        booking.pay_owner
    end
    Booking.where(end_date: 2.days.ago, state: 'credited').each do |booking|
        booking.settle_deposit
    end
  end
end