module Cangaroo
  class CreateOrUpdateItems
    prepend SimpleCommand

    def initialize(json_body, connection)
      @json_body = JSON.parse(json_body)
      @connection = connection
    end

    def call
      @json_body.map do |type, payloads|
        payloads.map do |payload|
          Cangaroo::Item.create_with!( item_type: type, payload: payload, connection: @connection )
        end
      end.flatten
    rescue ActiveRecord::RecordInvalid
      errors.add(:error, 'Error')
      []
    end
  end
end
