User.create!([
  {email: "nhayflick+1@gmail.com", password: 'foobar111', password_confirmation: 'foobar111', username: "rollthetapes", wepay_access_token: nil, wepay_account_id: nil, address: nil, longitude: nil, latitude: nil},
  {email: "nhayflick+3@gmail.com", password: 'foobar111', password_confirmation: 'foobar111', username: "scenius", wepay_access_token: nil, wepay_account_id: nil, address: nil, longitude: nil, latitude: nil},
  {email: "nhayflick@gmail.com", password: 'foobar111', password_confirmation: 'foobar111', username: "manhattoes", wepay_access_token: "STAGE_8486078a5d2614aafe78a7d0a765f5f7ed708573612d23e45e6feddcda98d363", wepay_account_id: 525219809, address: nil, longitude: nil, latitude: nil},
  {email: "nhayflick+5@gmail.com",  password: 'foobar111', password_confirmation: 'foobar111', username: "fission_mailed", wepay_access_token: "STAGE_8b0ced4b55b14025b98434525aadc4f0a26e0c1c5226df876c0a137aae412c6c", wepay_account_id: 516662033, address: nil, longitude: nil, latitude: nil}
])
Listing.create!([
  {user_id: 3, category: "Synthesizer", name: "ARP 2600", rate: 40, description: "So much synthy goodness"},
  {user_id: 3, category: "Pedal/Effects Unit", name: "Space Echo RE-201", rate: 20, description: "Dub god."},
  {user_id: 1, category: "Synthesizer", name: "Arutria Microbrute", rate: 20, description: "My first synth! Monosynth with CV gate section and mini-keyboard."}
])
ListingImage.create!([
  {listing_id: 1, image_file_name: "photo_(8).JPG", image_content_type: "image/jpeg", image_file_size: 514047, image_updated_at: "2013-12-07 19:30:45"},
  {listing_id: 3, image_file_name: "Screen_Shot_2013-11-27_at_6.09.13_PM.png", image_content_type: "image/png", image_file_size: 634569, image_updated_at: "2013-12-07 19:33:06"},
  {listing_id: 5, image_file_name: "w_roland_re201.1_a.jpg", image_content_type: "image/jpeg", image_file_size: 321223, image_updated_at: "2013-12-07 19:33:17"},
  {listing_id: 3, image_file_name: "ARP2600_Tonus.jpg", image_content_type: "image/jpeg", image_file_size: 95107, image_updated_at: "2013-12-07 23:23:47"}
])
Booking.create!([
  {user_id: 3, listing_id: 1, note: "Test rental", start_date: "2013-12-03", end_date: "2013-12-05", accepted_at: "2013-12-03 05:54:28", paid_at: nil, canceled_at: nil, state: "accepted"}
])
Reply.create!([
  {booking_id: 1, body: "No, but Tuesday might work?", read_at: nil, recipient_id: 2, sender_id: 1}
])
