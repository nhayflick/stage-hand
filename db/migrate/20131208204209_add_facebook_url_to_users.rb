class AddFacebookUrlToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_url, :string
  end

  def self.down
    remove_column :users, :facebook_url, :string
  end
end
