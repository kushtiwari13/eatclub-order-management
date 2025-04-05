class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.string :item_name
      t.integer :quantity
      t.integer :threshold

      t.timestamps
    end
  end
end
