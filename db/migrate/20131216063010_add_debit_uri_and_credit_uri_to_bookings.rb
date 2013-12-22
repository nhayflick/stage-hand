class AddDebitUriAndCreditUriToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :debit_uri, :string
    add_column :bookings, :credit_uri, :string
    add_column :bookings, :price, :integer
    add_column :bookings, :deposit_price, :integer, :default => 0
    add_column :listings, :deposit_price, :integer, :default => 0
  end
end
