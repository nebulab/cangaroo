require 'rails_helper'

module Cangaroo
  RSpec.describe Item, type: :model do

    let(:item) { Cangaroo::Item.new(payload: payload) }
    let(:payload) { { order: { id: 'R12345', amount: 5, discount: 10 } }.deep_stringify_keys }

    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:item_id) }
    it { is_expected.to validate_presence_of(:payload) }
    it { is_expected.to validate_uniqueness_of(:item_id).scoped_to(:type) }

    describe :fields do
      before { item.save }

      describe :type do
        subject { item.type }

        context 'when payload have the first key' do
          it { is_expected.to be_equal(:order) }
        end

        context 'when payload does not have the first key' do
          let(:payload) { {} }

          it { is_expected.to be_nil }
        end
      end

      describe :item_id do
        subject { item.item_id }

        context 'when payload have the first object with id' do
          it { is_expected.to eq('R12345') }
        end

        context 'when payload does not have the first object with id' do
          let(:payload) { { order: {} } }

          it { is_expected.to be_nil }
        end
      end

      describe :payload do
        subject { item.payload }

        context 'when new record' do
          it { is_expected.to eq(payload) }
        end

        context 'when old record' do
          it 'merges old payload with the new one' do
            item.payload = { order: { id: 'R12345', amount: 10 } }
            item.save
            expect(item.payload).to eq({ order: { id: 'R12345', amount: 10, discount: 10 } }.deep_stringify_keys)
          end
        end
      end
    end
  end
end
