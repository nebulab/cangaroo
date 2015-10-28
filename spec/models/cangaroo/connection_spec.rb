require 'rails_helper'

module Cangaroo
  RSpec.describe Connection, type: :model do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_presence_of(:token) }

    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:url) }
    it { is_expected.to validate_uniqueness_of(:key) }
    it { is_expected.to validate_uniqueness_of(:token) }
  end
end
