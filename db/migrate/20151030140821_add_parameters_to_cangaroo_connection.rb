class AddParametersToCangarooConnection < SolidusSupport::Migration[4.2]
  def change
    add_column :cangaroo_connections, :parameters, :text
  end
end
