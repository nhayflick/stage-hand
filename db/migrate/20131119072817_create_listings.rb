class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.integer :user_id
      t.string :category
      t.string :name
      t.integer :rate
      t.text :description

      t.timestamps
    end
  end
end
