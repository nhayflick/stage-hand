class FixDbSpelling < ActiveRecord::Migration
  def change
  		rename_column :users, :wepay_acount_id, :wepay_account_id
  end
end
