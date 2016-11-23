require 'rails_helper'

describe Cangaroo::AuthenticateConnection do
  let(:connection) { create(:cangaroo_connection) }
  let(:connection_key) { connection.key }
  let(:connection_token) { connection.token }

  subject(:context) do
    Cangaroo::AuthenticateConnection.call(key: connection_key,
                                          token: connection_token,
                                          guid: SecureRandom.uuid)
  end

  describe '.call' do
    context 'when given valid credentials' do
      it 'succeeds' do
        expect(context).to be_a_success
      end

      it 'provides the connection' do
        expect(context.source_connection).to eq(connection)
      end
    end

    context 'when given invalid credentials' do
      let(:connection_token) { 'wrong_token' }

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
