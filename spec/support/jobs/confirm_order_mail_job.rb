module Cangaroo
  class ConfirmOrderMailJob < PushJob
    connection :mail
    path '/send_confirmation_order_email'

    def perform?
      type == 'orders' && payload['state'] == 'confirmed'
    end
  end
end
