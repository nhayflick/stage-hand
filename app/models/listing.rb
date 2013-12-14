class Listing < ActiveRecord::Base
	#categories are synthesizer, guitar, bass, drums and percussion, effects unit, speaker, amplifier, keyboard, midi controller, mixer, microphone
	validate :has_images?, before: [:create, :update]
	validates :name, length: { in: 3..40 }
	validates :description, length: { in: 5..1000 }
	validates :category, inclusion: {in: ['Synthesizer', 'Guitar', 'Bass', 'Drums/Percussion', 'Pedal/Effects Unit', 'Speaker', 'Amplifier', 'Keyboard', 'Midi Controller', 'Mixer', 'Microphone', 'Other']}

	belongs_to :user
	has_many :notifications, as: :notifiable
	has_many :bookings
	has_many :listing_images

	accepts_nested_attributes_for :listing_images, reject_if: :all_blank

	geocoded_by "user.zipcode"
 	reverse_geocoded_by "users.latitude", "users.longitude"

	def has_images?
		errors.add(:base, "Please upload at least one image for potential renters to check out.") if self.listing_images.blank?
	end

	def self.categories
		return ['Synthesizer', 'Guitar', 'Bass', 'Drums/Percussion', 'Pedal/Effects Unit', 'Speaker', 'Amplifier', 'Keyboard', 'Midi Controller', 'Mixer', 'Microphone', 'Other']
	end

end
