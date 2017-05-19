module Cangaroo
  class ErpJob < PushJob
    connection :erp
    path '/add_order'

    def perform?
      type == 'orders' && payload['state'] == 'payed'
    end
  end
end
