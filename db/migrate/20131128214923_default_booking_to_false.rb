class DefaultBookingToFalse < ActiveRecord::Migration
  def change
  	remove_column :bookings, :accepted, :boolean
  	add_column :bookings, :accepted_at, :datetime
  	add_column :bookings, :paid_at, :datetime
  	add_column :bookings, :canceled_at, :datetime
  end
end
