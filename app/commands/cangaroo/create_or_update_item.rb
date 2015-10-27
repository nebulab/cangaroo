module Cangaroo
  class CreateOrUpdateItem
    prepend SimpleCommand

    def initialize(json_body)
      @json_body = json_body
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
      @item ||= Cangaroo::Item.where(type: type, item_id: item_id).first_or_initialize
    end

    def type
      parse_json_body.keys.first.to_sym
    end

    def item_id
      parse_json_body[type.to_s]['id']
    end

    def payload
      if item.payload
        item.payload.deep_merge(parse_json_body)
      else
        parse_json_body
      end
    end

    def parse_json_body
      JSON.parse(@json_body)
    end
  end
end
