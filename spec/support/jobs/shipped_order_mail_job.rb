module Cangaroo
  class ShippedOrderMailJob < PushJob
    connection :mail
    path '/send_shipped_order_email'

    def perform?
      type == 'orders' && payload['state'] == 'shipped'
    end
  end
end
