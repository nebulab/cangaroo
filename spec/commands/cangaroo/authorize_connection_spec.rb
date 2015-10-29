require 'rails_helper'

module Cangaroo
  RSpec.describe AuthorizeConnection do
    let(:connection) { create :cangaroo_connection }

    describe '#call' do
      before do
        command.call
      end

      context 'when connection is found' do
        let(:command) { AuthorizeConnection.new(connection.key, connection.token) }

        it 'returns the connection' do
          expect(command.result).to eq(connection)
        end
      end

      context 'when connection is not found' do
        let(:command) { AuthorizeConnection.new('wrong', 'credential') }

        it 'adds an error' do
          expect(command.errors[:authentication]).not_to be_empty
        end

        it 'returns false' do
          expect(command.result).to be false
        end
      end
    end
  end
end
