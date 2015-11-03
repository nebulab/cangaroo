require 'rails_helper'

module Cangaroo
  RSpec.describe EndpointController, type: :controller do
    routes { Cangaroo::Engine.routes }
    let(:connection) { create :cangaroo_connection }
    let(:request_payload) { JSON.parse(load_fixture('json_payload_ok.json')) }
    # let(:request_headers) {
    #   {
    #     'X-Hub-Store' => connection.key,
    #     'X-Hub-Access-Token' => connection.token,
    #     'Accept' => 'application/json'
    #   }
    # }

    before do
      request.headers['Accept'] = 'application/json'
      request.headers['X-Hub-Store'] = connection.key
      request.headers['X-Hub-Access-Token'] = connection.token
    end

    describe '#create' do
      before do
        post :create, request_payload
      end

      it 'accepts only application/json requests' do
        expect(response.status).to eq(200)

        request.headers['Accept'] = 'text/html'
        post :create
        expect(response.status).to eq(406)
      end

      context 'when success' do
        let(:auth_headers) {}

        it 'responds with 200' do
          expect(response.status).to eq(200)
        end

        it 'responds with the number of objects received in payload' do
          res = JSON.parse(response.body)
          expect(res).to eq({"orders" => 2, "shipments" => 2})
        end
      end

      context 'when error' do
        it 'responds with 500'
        it 'responds with error messages in the body'
      end
    end
  end
end
