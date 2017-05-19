module Cangaroo
  class StoreJob < PushJob
    connection :store
    path '/update_order'

    def perform?
      type == 'orders' && %w(confirmed shipped).include?(payload['state'])
    end
  end
end
