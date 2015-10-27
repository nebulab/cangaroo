module Cangaroo
  class Item
    include Mongoid::Document
    include Mongoid::Timestamps

    field :type, type: Symbol
    field :item_id, type: String
    field :payload, type: Hash

    index({ type: 1, item_id: 1 }, { unique: true, background: true })

    validates :type, :item_id, :payload, presence: true
    validates :item_id, uniqueness: { scope: :type }

    before_validation :stringify_payload_keys,
                      :set_type_from_payload,
                      :set_item_id_from_payload

    before_validation :merge_payload, unless: :new_record?

    private

    def stringify_payload_keys
      self.payload = self.payload.deep_stringify_keys
    end

    def merge_payload
      self.payload = self.payload_was.deep_merge(self.payload)
    end

    def set_type_from_payload
      self.type = self.payload.keys.first.to_s if self.payload.keys.any?
    end

    def set_item_id_from_payload
      self.item_id = self.payload[self.type.to_s]['id'] if self.type
    end
  end
end
