class AddCangarooConnectionToCangarooItem < ActiveRecord::Migration
  def change
    add_reference :cangaroo_items, :cangaroo_connection, index: true, foreign_key: true
  end
end
