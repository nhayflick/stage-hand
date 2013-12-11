class BookingMailer < ActionMailer::Base
  default from: "bookings@scenius.co"

  def booking_requested_email(booking)
    @booking = booking
    mail(to: @booking.recipient.email, subject: 'A Scenius Member Requested A Booking!')
  end

end
