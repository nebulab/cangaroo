require 'rails_helper'

module Cangaroo
  RSpec.describe CreateOrUpdateItems do
    let(:command) { CreateOrUpdateItems.new(body) }

    describe '#call' do
      let(:order_item) { Cangaroo::Item.find_by(item_type: 'orders', item_id: 'O154085346172') }
      let(:shipment_item) { Cangaroo::Item.find_by(item_type: 'shipments', item_id: 'S53454325') }

      context 'when all items are new' do
        let(:body) {
          { orders: [
              { id: 'O154085346172', state: 'cart' },
            ],
            shipments: [
              { id: 'S53454325', state: 'shipped' },
            ]
          }.to_json
        }

        it 'returns the list of saved items' do
          command.call
          expect(command.result).to eq(Cangaroo::Item.all)
        end

        it 'creates the new items' do
          expect{command.call}.to change{Cangaroo::Item.count}.by(2)
        end

        it 'saves the new items with correct item_type and item_id' do
          command.call
          expect(order_item).to_not be_new_record
          expect(shipment_item).to_not be_new_record
        end

        it 'sets the items payload' do
          command.call
          expect(order_item.payload).to eq({ id: 'O154085346172', state: 'cart' }.deep_stringify_keys)
          expect(shipment_item.payload).to eq({ id: 'S53454325', state: 'shipped' }.deep_stringify_keys)
        end
      end

      context 'failure' do
        let(:body) {
          { orders: [
              { state: 'cart' },
            ],
            shipments: [
              { id: 'S53454325', state: 'shipped' },
            ]
          }.to_json
        }

        before { command.call }

        it 'returns false' do
          expect(command.result).to be false
        end

        it 'fails' do
          expect(command).to be_failure
        end

        it 'adds an error' do
          expect(command.errors[:item_errors]).not_to be_empty
        end
      end
    end
  end
end
