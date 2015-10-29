module Cangaroo
  class CreateOrUpdateItems
    prepend SimpleCommand

    def initialize(json_body)
      @json_body = JSON.parse(json_body)
    end

    def call
      begin
        items = []
        @json_body.each do |type, payloads|
          items << first_or_initialize_items(type, payloads)
        end
        items.flatten
      rescue ActiveRecord::RecordInvalid
        errors.add(:item_errors, 'Error')
        false
      end
    end

    private

    def first_or_initialize_items(type, payloads)
      payloads.map do |payload|
        item = Cangaroo::Item.where(item_type: type, item_id: payload['id']).first_or_initialize
        item.payload = merge_payload(item.payload, payload)
        item.save!
        item
      end
    end

    def merge_payload(item_payload, payload)
      item_payload ? item_payload.deep_merge(payload) : payload
    end
  end
end
