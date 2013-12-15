class AddSoundcloudIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :soundcloudID, :integer
  end
end
