class Request < ActiveRecord::Base
	validates :user, :listing, presence: :true

	belongs_to :user
	belongs_to :listing
end