module Cangaroo
  class WarehouseJob < PushJob
    connection :warehouse
    path '/add_shipment'

    def perform?
      type == 'orders' && payload['state'] == 'confirmed'
    end
  end
end
