module Cangaroo
  class Job < ActiveJob::Base
    include Cangaroo::ClassConfiguration

    queue_as :cangaroo

    class_configuration :connection
    class_configuration :path, ''
    class_configuration :parameters, {}

    def perform(*)
      restart_flow(connection_request)
    end

    def perform?
      fail NotImplementedError
    end

    def transform
      { type.singularize => payload }
    end

    protected

    def connection_request
      Cangaroo::Webhook::Client.new(destination_connection, path)
        .post(transform, @job_id, parameters)
    end

    def restart_flow(response)
      # if no json was returned, the response should be discarded
      return if response.blank?

      PerformFlow.call(
        source_connection: destination_connection,
        json_body: response.to_json,
        jobs: Rails.configuration.cangaroo.jobs
      )
    end

    def source_connection
      arguments.first.fetch(:connection)
    end

    def type
      arguments.first.fetch(:type)
    end

    def payload
      arguments.first.fetch(:payload)
    end

    def destination_connection
      @connection ||= Cangaroo::Connection.find_by!(name: connection)
    end
  end
end
