class AddWepayAccessTokenWepayAccountIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :wepay_access_token, :string
    add_column :users, :wepay_acount_id, :integer
  end
end
