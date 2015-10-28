module Cangaroo
  class Item < ActiveRecord::Base
    validates :item_type, :item_id, :payload, presence: true
    validates :item_id, uniqueness: { scope: :item_type }
  end
end
