class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.integer :booking_id
      t.string :body
      t.date :read_at
      t.integer :recepient_id
      t.integer :sender_id

      t.timestamps
    end
  end
end
