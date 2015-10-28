class CreateCangarooItems < ActiveRecord::Migration
  def change
    create_table :cangaroo_items do |t|
      t.string :item_type
      t.string :item_id
      t.json :payload

      t.timestamps null: false
    end
  end
end
