class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :body
      t.integer :recipient_id
      t.integer :notifiable_id
      t.string :notifiable_type
      t.boolean :viewed, :default => false

      t.timestamps
    end
    add_index :notifications, [:notifiable_type, :notifiable_id]
    add_index :notifications, :recipient_id
  end
end
