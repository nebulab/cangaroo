require 'rails_helper'

module Cangaroo
  RSpec.describe EndpointController, type: :controller do
    routes { Cangaroo::Engine.routes }

    let(:request_headers) { { 'Accept': 'application/json' } }

    it 'accepts only application/json requests' do
      post :create, nil, request_headers
      expect(response.status).to eq(200)

      post :create, nil, { 'Accept': 'text/html' }
      expect(response.status).to eq(500)
    end

    it 'accepts only post method requests'

    describe 'success' do
      it 'responds with 200'
      it 'responds with empty body'
    end

    describe 'error' do
      it 'responds with 500'
      it 'responds with error messages in the body'
    end

  end
end
