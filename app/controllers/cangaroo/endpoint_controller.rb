require_dependency 'cangaroo/application_controller'

module Cangaroo
  class EndpointController < ApplicationController
    before_action :ensure_json_request
    before_action :handle_request

    rescue_from Exception, with: :handle_error

    def create
      if @command.success?
        render json: @command.object_count, status: 202
      else
        render json: { error: @command.message },
               status: @command.error_code
      end
    end

    private

    def handle_error(exception)
      raise(exception) if Rails.env.development?
      render json: { error: 'Something went wrong!' }, status: 500
    end

    def handle_request
      @command = HandleRequest.call(
        key: key,
        token: token,
        json_body: params[:endpoint].to_json,
        jobs: Rails.configuration.cangaroo.jobs
      )
    end

    def ensure_json_request
      return if request.headers['Content-Type'] == 'application/json'

      render nothing: true, status: 406
    end

    def key
      return user if Rails.configuration.cangaroo.basic_auth
      request.headers['X-Hub-Store']
    end

    def token
      return password if Rails.configuration.cangaroo.basic_auth
      request.headers['X-Hub-Access-Token']
    end

    def user
      user_and_password.try(:first)
    end

    def password
      user_and_password.try(:last)
    end

    def user_and_password
      return nil unless ActionController::HttpAuthentication::Basic.has_basic_credentials?(request)

      ActionController::HttpAuthentication::Basic.user_name_and_password(request)
    end
  end
end
