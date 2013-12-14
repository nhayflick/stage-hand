class BookingMailer < ActionMailer::Base
  default from: "bookings@scenius.co"

  def booking_requested_email(booking)
    @booking = booking
    mail(to: @booking.recipient.email, subject: 'A Scenius Member Requested A Booking!')
  end

  def booking_accepted_email(booking)
  	@booking = booking
  	mail(to: @booking.sender.email, subject: 'Your Scenius Booking Request Was Accepted!')
  end
end
