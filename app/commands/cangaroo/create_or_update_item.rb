module Cangaroo
  class CreateOrUpdateItem
    prepend SimpleCommand

    def initialize(json_body)
      @json_body = JSON.parse(json_body)
    end

    def call
      item.payload = payload
      unless item.save
        item.errors.each { |err| errors.add(:item_errors, err) }
        return false
      end
      true
    end

    private

    def item
      @item ||= Cangaroo::Item.where(item_type: type, item_id: item_id).first_or_initialize
    end

    def type
      @json_body.keys.first
    end

    def item_id
      @json_body[type]['id']
    end

    def payload
      item.payload ? item.payload.deep_merge(@json_body) : @json_body
    end
  end
end
