class RemoveLatitudeAndLongitudeFromUser < ActiveRecord::Migration
  def change
  	    remove_column :users, :latitude, :float
   		remove_column :users, :longitude, :float
   		remove_column :users, :address, :string
  end
end
