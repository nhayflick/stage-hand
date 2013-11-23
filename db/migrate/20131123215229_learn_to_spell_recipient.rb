class LearnToSpellRecipient < ActiveRecord::Migration
  def change
  	rename_column :replies, :recepient_id, :recipient_id
  end
end
