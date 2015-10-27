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

    before_validation :stringify_payload_keys

    private

    def stringify_payload_keys
      self.payload = self.payload.deep_stringify_keys
    end
  end
end
