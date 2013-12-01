class OrderCompletion
  attr_accessor :booking

  def initialize(booking)
    @booking = booking
  end

  def create
    if self.booking.save
      booking.sender.notify(
        'Booking accepted!',
        '#{booking.recipient.username.capitalize} accepted your booking request for #{booking.listing.name})! Enter your payment info to confirm your reservation!',
        booking)
    end
  end
end
