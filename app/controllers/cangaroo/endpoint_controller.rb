require_dependency "cangaroo/application_controller"

module Cangaroo
  class EndpointController < ApplicationController
    before_action :ensure_json_request
    before_action :handle_request

    def create
      render json: @command.success? ? @command.result : {error: @command.errors[:error].first}
    end

    private

    def handle_request
      puts "PARAMS #{params.inspect}"
      key = request.headers["X-Hub-Store"]
      token = request.headers["X-Hub-Access-Token"]
      puts "key #{key} - token #{token}"
      @command = HandleRequest.call params, key, token
    end

    def ensure_json_request
      return if request.headers['Accept'] == 'application/json'
      render nothing: true, status: 406
    end
  end
end
