json.array!(@requests) do |request|
  json.extract! request, :user_id, :listing_id, :note, :start_date, :end_date, :accepted
  json.url request_url(request, format: :json)
end
