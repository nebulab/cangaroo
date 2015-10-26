require_dependency "cangaroo/application_controller"

module Cangaroo
  class EndpointController < ApplicationController
    before_action :ensure_json_request

    def create
      render nothing: true
    end

    private

    def ensure_json_request
      return if request.headers['Accept'] == 'application/json'
      render nothing: true, status: 406
    end
  end
end
