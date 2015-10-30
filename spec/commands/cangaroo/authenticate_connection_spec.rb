require 'rails_helper'

module Cangaroo
  RSpec.describe AuthenticateConnection do
    let(:connection) { create :cangaroo_connection }

    describe '#call' do
      before do
        command.call
      end

      context 'when connection is found' do
        let(:command) { AuthenticateConnection.new(connection.key, connection.token) }

        it 'returns the connection' do
          expect(command.result).to eq(connection)
        end
      end

      context 'when connection is not found' do
        let(:command) { AuthenticateConnection.new('wrong', 'credential') }

        it 'adds an error' do
          expect(command.errors[:error]).not_to be_empty
        end

        it 'returns false' do
          expect(command.result).to be nil
        end
      end
    end
  end
end
