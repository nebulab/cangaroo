require 'rails_helper'

module Cangaroo
  RSpec.describe Item, type: :model do
    let(:item_attributes) { attributes_for(:cangaroo_item) }
    let(:payload) { item_attributes[:payload] }
    let(:item_type) { item_attributes[:item_type] }
    let(:connection) { create(:cangaroo_connection) }

    it { is_expected.to validate_presence_of(:item_type) }
    it { is_expected.to validate_presence_of(:item_id) }
    it { is_expected.to validate_presence_of(:payload) }
    it { is_expected.to validate_presence_of(:connection) }
    it { is_expected.to validate_uniqueness_of(:item_id).scoped_to(:item_type) }

    it { is_expected.to belong_to(:connection).with_foreign_key(:cangaroo_connection_id) }

    describe '.create_with!' do
      let(:create_with!) do
        Cangaroo::Item.create_with!(
          item_type: item_type,
          payload: payload,
          connection: connection
        )
      end

      context 'when item not exists' do
        it 'creates a new item' do
          expect{ create_with! }.to change{Cangaroo::Item.count}.by(1)
        end

        it 'returns the new item' do
          expect( create_with! ).to be_instance_of(Cangaroo::Item)
        end
      end

      context 'when item exists' do
        before do
          create_with!
        end

        let(:new_payload) { { id: payload[:id], state: 'confirmed' } }
        let(:merged_payload) { payload.deep_merge(new_payload) }
        let(:new_connection) { create(:cangaroo_connection, name: 'a connection', url: 'test.com', key: '1234', token: '1234') }
        let(:item) { Cangaroo::Item.create_with!( item_type: item_type, payload: new_payload, connection: new_connection ) }

        it 'does not create a new item' do
          expect{create_with!}.to change{Cangaroo::Item.count}.by(0)
        end

        it 'merges the payload' do
          expect(item.payload).to eq(merged_payload.deep_stringify_keys)
        end

        it 'does not update the connection' do
          expect(item.connection).to eq(connection)
        end
      end
    end

    describe '#payload=' do
      let(:item) { build(:cangaroo_item) }

      context 'when new record' do
        it 'sets the payload' do
          expect(item.payload).to eq(payload.deep_stringify_keys)
        end
      end

      context 'when saved record' do
        it 'merges old payload with the new one' do
          item.payload = { id: 'R12345', amount: 10 }
          expect(item.payload).to eq({ id: 'R12345', amount: 10, discount: 10 }.deep_stringify_keys)
        end
      end
    end
  end
end
