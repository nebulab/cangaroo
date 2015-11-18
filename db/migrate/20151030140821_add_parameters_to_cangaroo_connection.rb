class AddParametersToCangarooConnection < ActiveRecord::Migration
  def change
    add_column :cangaroo_connections, :parameters, :text, default: {}
  end
end
