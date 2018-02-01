require 'rails_helper'

module Cangaroo
  RSpec.describe :Endpoint, type: :request do
    let(:connection) { create :cangaroo_connection }
    let(:request_payload) { load_fixture('json_payload_ok.json') }
    let(:headers) {
      { 'Content-Type' => 'application/json',
        'X-Hub-Store' => connection.key,
        'X-Hub-Access-Token' => connection.token }
    }

    context 'when wombat authentication is enabled' do
      describe '#create' do
        before do
          post endpoint_index_path, params: request_payload, headers: headers
        end

        it 'accepts only application/json requests' do
          expect(response.status).to eq(202)

          headers['Content-Type'] = 'text/html'
          post endpoint_index_path, params: {}, headers: headers
          expect(response.status).to eq(406)
        end

        context 'when success' do
          it 'responds with 200' do
            expect(response.status).to eq(202)
          end

          it 'responds with the number of objects received in payload' do
            res = JSON.parse(response.body)
            expect(res).to eq('orders' => 2, 'shipments' => 2,
                              'line_items' => 0, 'line-items' => 0)
          end
        end

        context 'when error' do
          before do
            headers['X-Hub-Access-Token'] = 'wrongtoken'
            post endpoint_index_path, params: request_payload, headers: headers
          end

          it 'responds with the command error code' do
            expect(response.status).to eq(401)
          end

          it 'responds with error messages in the body' do
            expect(JSON.parse(response.body)['error']).to be_present
          end
        end

        context 'when an exception was raised' do
          before do
            allow(HandleRequest).to receive(:call).and_raise('An error')
            post endpoint_index_path, params: request_payload, headers: headers
          end

          it 'responds with 500' do
            expect(response.status).to eq(500)
          end

          it 'responds with error messages in the body' do
            expect(JSON.parse(response.body)['error']).to eq 'Something went wrong!'
          end
        end
      end
    end

    context 'when basic auth is enabled' do
      before do
        Rails.configuration.cangaroo.basic_auth = true
      end

      describe '#create' do
        it 'successfully authorized against a connection key and token' do
          headers['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(connection.key, connection.token)

          post endpoint_index_path, params: request_payload, headers: headers

          expect(response.status).to eq(202)
        end

        it 'successfully authenticates against a connection token' do
          connection.update(key: '')

          headers['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('', connection.token)

          post endpoint_index_path, params: request_payload, headers: headers

          expect(response.status).to eq(202)
        end

        it 'fails to authenticate when basic auth is not provided' do
          post endpoint_index_path, params: request_payload, headers: headers

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
