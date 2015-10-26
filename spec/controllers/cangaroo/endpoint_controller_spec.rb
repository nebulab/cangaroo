require 'rails_helper'

module Cangaroo
  RSpec.describe EndpointController, type: :controller do
    routes { Cangaroo::Engine.routes }

    before do
      request.headers['Accept'] = 'application/json'
    end

    it 'accepts only application/json requests' do
      post :create
      expect(response.status).to eq(200)

      request.headers['Accept'] = 'text/html'
      post :create
      expect(response.status).to eq(406)
    end

    describe 'success' do
      it 'responds with 200' do
        post :create
        expect(response.status).to eq(200)
      end

      it 'responds with empty body'
    end

    describe 'error' do
      it 'responds with 500'
      it 'responds with error messages in the body'
    end

  end
end
