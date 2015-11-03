require 'rails_helper'

module Cangaroo
  module Webhook
    RSpec.describe Client do

      let(:client) { Client.new(connection, '/api_path') }

      let(:connection) { create(:cangaroo_connection) }

      let(:url) { "http://#{connection.url}/api_path" }

      let(:request_id) { '123456' }
      let(:parameters) { { email: 'info@nebulab.it' } }
      let(:payload) { { order: { id: 'R12345', state: 'completed' }}}

      let(:response) {
        { "request_id": "52f367367575e449c3000001",
          "summary": "Successfully updated inventory for ROR-7890123" }
      }

      before do
        stub_request(:post, /^#{url}.*/).to_return(body: response.to_json, status: 200)
      end

      describe '.post' do
        it 'makes the post request with correct url, headers, query and body' do
          client.post(payload, request_id, parameters)
          expect(WebMock).to have_requested(:post, "http://www.store.com/api_path?first=first&second=second").with({
            headers: { 'X-Hub-Store': connection.key, 'X-Hub-Token': connection.token },
            body: {
              request_id: request_id,
              parameters: parameters,
              order: { id: 'R12345', state: 'completed' }
            }.to_json
          })
        end

        context 'when response code is 200 (success)' do
          it 'returns the parsed response' do
            expect(client.post(payload, request_id, parameters)).to eq(response.stringify_keys)
          end
        end

        context 'when response code is not 200 (success)' do
          let(:failure_response) {
            {
              "request_id": "52f367367575e449c3000001",
              "summary": "Cannot update inventory. Product ROR-7890123 not found in storefront."
            }
          }

          before do
            stub_request(:post, /^#{url}.*/).to_return(body: failure_response.to_json, status: 500)
          end

          it 'raises Cangaroo::Webhook::Error' do
            expect{client.post(payload, request_id, parameters)}.to raise_error(Cangaroo::Webhook::Error)
          end
        end
      end
    end
  end
end
