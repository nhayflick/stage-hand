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

  def booking_remind_owner_email(booking)
    @booking = booking
    mail(to: @booking.recipient.email, subject: 'Your Scenius Rental is Today!')
  end

  def booking_remind_renter_email(booking)
    @booking = booking
    mail(to: @booking.sender.email, subject: 'Your Scenius Rental is Today!')
  end

  def booking_canceled_email(booking)
    @booking = booking
    mail(to: @booking.sender.email, subject: 'Scenius Booking Canceled')
  end

  def booking_payment_failed_email(booking)
    @booking = booking
    mail(to: @booking.sender.email, subject: 'Scenius Booking Failed')
  end
end
