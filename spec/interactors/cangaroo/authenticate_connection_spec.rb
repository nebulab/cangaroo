require 'rails_helper'

describe Cangaroo::AuthenticateConnection do
  subject(:context) { Cangaroo::AuthenticateConnection.call(key: 'connection_key', token: 'secret_token') }

  describe '.call' do
    context 'when given valid credentials' do
      let(:connection) { double(:connection) }

      before do
        allow(Cangaroo::Connection).to receive(:authenticate).with('connection_key', 'secret_token').and_return(connection)
      end

      it 'succeeds' do
        expect(context).to be_a_success
      end

      it 'provides the connection' do
        expect(context.source_connection).to eq(connection)
      end
    end

    context 'when given invalid credentials' do
      before do
        allow(Cangaroo::Connection).to receive(:authenticate).with('connection_key', 'secret_token').and_return(nil)
      end

      it 'fails' do
        expect(context).to be_a_failure
      end

      it 'provides a failure message' do
        expect(context.message).to be_present
      end

      it 'provides a failure error code' do
        expect(context.error_code).to eq 401
      end
    end
  end
end
