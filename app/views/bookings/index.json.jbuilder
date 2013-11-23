json.array!(@bookings) do |booking|
  json.extract! booking, :user_id, :listing_id, :note, :start_date, :end_date, :accepted
  json.url booking_url(booking, format: :json)
end
