require 'rails_helper'

module Cangaroo
  RSpec.describe CreateOrUpdateItem do
    let(:command) { CreateOrUpdateItem.new(body.to_json) }

    describe '#call' do
      context 'when item is a new one' do
        let(:body) { { order: { id: 'R154085346172', amount: 10 } } }
        let(:item) { Cangaroo::Item.last }

        it 'returns true' do
          command.call
          expect(command.result).to be true
        end

        it 'creates a new item' do
          expect{command.call}.to change{Cangaroo::Item.count}.by(1)
        end

        it 'sets the type from the first key of the payload' do
          command.call
          expect(item.item_type).to eq('order')
        end

        it 'sets the item_id from id into the first object of the payload' do
          command.call
          expect(item.item_id).to eq('R154085346172')
        end

        it 'sets the payload' do
          command.call
          expect(item.payload).to eq(body.deep_stringify_keys)
        end
      end

      context 'when it is an old item' do
        let!(:item) {
          Cangaroo::Item.create( item_type: :order,
                                 item_id: 'R154085346172',
                                 payload: { order: { id: 'R154085346172', amount: 10 } } )
        }
        let(:body) { { order: { id: 'R154085346172', discount: 5 } } }

        it 'returns true' do
          command.call
          expect(command.result).to be true
        end

        it 'does not creates a new item' do
          expect{command.call}.to change{Cangaroo::Item.count}.by(0)
        end

        it 'merges the old item payload with the new one' do
          command.call
          expect(item.reload.payload).to eq({ order: { id: 'R154085346172', amount: 10, discount: 5 }}.deep_stringify_keys)
        end
      end

      context 'when item can not be saved for some validation errors' do
        let(:body) { { order: { discount: 5 } } }

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
