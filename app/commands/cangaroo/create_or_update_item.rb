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
      @json_body.keys.first.to_sym
    end

    def item_id
      @json_body[type.to_s]['id']
    end

    def payload
      if item.payload
        item.payload.deep_merge(@json_body)
      else
        @json_body
      end
    end
  end
end
