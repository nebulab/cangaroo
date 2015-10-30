module Cangaroo
  class Item < ActiveRecord::Base
    validates :item_type, :item_id, :payload, presence: true
    validates :item_id, uniqueness: { scope: :item_type }

    def payload=(new_payload)
      super(payload ? payload.deep_merge(new_payload) : new_payload)
    end

    def self.create_with!(attributes)
      attributes.deep_symbolize_keys!
      item = self.where(item_type: attributes[:item_type],
                 item_id: attributes[:payload][:id]).first_or_initialize
      item.payload = attributes[:payload]
      item.save!
      item
    end
  end
end
