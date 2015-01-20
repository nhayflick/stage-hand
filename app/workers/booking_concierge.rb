class BookingConcierge
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options :queue => :often

  recurrence { daily }

  recurrence backfill: true do
    hourly
  end

  def perform(last_occurrence, current_occurrence)
    Booking.where(start_date: Date.today, state: 'paid').each do |booking|
        booking.start
    end
    Booking.where(start_date: 2.days.ago, state: 'started').each do |booking|
        booking.credit
    end
    Booking.where(end_date: 2.days.ago, state: 'credited').each do |booking|
        booking.settle
    end
  end
end