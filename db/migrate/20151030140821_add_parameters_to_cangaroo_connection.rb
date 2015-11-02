class AddParametersToCangarooConnection < ActiveRecord::Migration
  def change
    add_column :cangaroo_connections, :parameters, :text
  end
end
