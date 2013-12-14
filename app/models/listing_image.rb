class ListingImage < ActiveRecord::Base

	has_attached_file :image, :styles => {
	    thumb: '100x100#',
	    square: '200x200#',
	    medium: '300x300>'
	}

	process_in_background :image


  	validates_attachment :image, :presence => true, :size => { :in => 0..5.megabytes }
  	validates_attachment_content_type :image, :content_type => /image/

  	belongs_to :listing

end
