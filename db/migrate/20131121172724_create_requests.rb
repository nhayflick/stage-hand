class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :user_id
      t.integer :listing_id
      t.text :note
      t.date :start_date
      t.date :end_date
      t.boolean :accepted

      t.timestamps
    end
  end
end
