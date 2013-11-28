class AddImageToListingImages < ActiveRecord::Migration
   def self.up
    add_attachment :listing_images, :image
  end

  def self.down
    remove_attachment :listing_images, :image
  end
end
