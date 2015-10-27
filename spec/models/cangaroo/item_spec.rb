require 'rails_helper'

module Cangaroo
  RSpec.describe Item, type: :model do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:item_id) }
    it { is_expected.to validate_presence_of(:payload) }
    it { is_expected.to validate_uniqueness_of(:item_id).scoped_to(:type) }
  end
end
