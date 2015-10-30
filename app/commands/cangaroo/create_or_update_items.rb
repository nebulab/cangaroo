module Cangaroo
  class CreateOrUpdateItems
    prepend SimpleCommand

    def initialize(json_body)
      @json_body = JSON.parse(json_body)
    end

    def call
      @json_body.map do |type, payloads|
        payloads.map do |payload|
          Cangaroo::Item.create_with!( item_type: type, payload: payload )
        end
      end.flatten
    rescue ActiveRecord::RecordInvalid
      errors.add(:item_errors, 'Error')
      false
    end
  end
end
