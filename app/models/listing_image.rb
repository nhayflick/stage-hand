class ListingImage < ActiveRecord::Base

	has_attached_file :image, :styles => {
	    thumb: '-quality 80 100x100>',
	    square: '-quality 80 200x200#',
	    medium: '-quality 80 300x300>'
	}

  	validates_attachment :image, :presence => true, :content_type => { :content_type => ["image/jpg", "image/png"] }, :size => { :in => 0..5.megabytes }

  	belongs_to :listing

end
