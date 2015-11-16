require_dependency "cangaroo/application_controller"

module Cangaroo
  class EndpointController < ApplicationController
    before_action :ensure_json_request
    before_action :handle_request

    def create
      if @command.success?
        render json: @command.object_count
      else
        render json: { error: @command.message },
               status: @command.error_code
      end
    end

    private

    def handle_request
      @command = HandleRequest.call(
        key: key,
        token: token,
        json_body: params[:endpoint].to_json,
        jobs: Rails.configuration.cangaroo.jobs
      )
    end

    def ensure_json_request
      return if request.headers['Accept'] == 'application/json' && request.headers['Content-Type'] == 'application/json'
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
