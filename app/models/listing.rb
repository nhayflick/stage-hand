class Listing < ActiveRecord::Base
	validate :has_images?, before: [:create, :update]
	validates :name, length: { in: 3..40 }
	validates :description, length: { in: 5..1000 }

	belongs_to :user
	has_many :bookings
	has_many :listing_images

	accepts_nested_attributes_for :listing_images, reject_if: :all_blank

	def has_images?
		errors.add(:base, "Please upload at least one image for potential renters to check out.") if self.listing_images.blank?
	end
end
