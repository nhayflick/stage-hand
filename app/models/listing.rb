class Listing < ActiveRecord::Base
	belongs_to :user
	has_many :bookings
	has_many :listing_images

	accepts_nested_attributes_for :listing_images, reject_if: :all_blank
end
