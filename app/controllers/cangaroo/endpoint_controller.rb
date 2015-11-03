require_dependency "cangaroo/application_controller"

module Cangaroo
  class EndpointController < ApplicationController
    before_action :ensure_json_request
    before_action :handle_request

    def create
      if @command.success?
        render json: @command.result
      else
        render json: { error: @command.errors[:error].first }, status: 500
      end
    end

    private

    def handle_request
      @command = HandleRequest.call request.request_parameters.to_json, key, token
    end

    def ensure_json_request
      return if request.headers['Accept'] == 'application/json'
      render nothing: true, status: 406
    end

    def key
      request.headers["X-Hub-Store"]
    end

    def token
      request.headers["X-Hub-Access-Token"]
    end

  end
end
