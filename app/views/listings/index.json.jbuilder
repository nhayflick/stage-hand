json.array!(@listings) do |listing|
  json.extract! listing, :user_id, :category, :name, :rate, :description
  json.url listing_url(listing, format: :json)
end
