require_dependency "cangaroo/application_controller"

module Cangaroo
  class EndpointController < ApplicationController
    def create
      render nothing: true
    end
  end
end
