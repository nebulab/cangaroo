module Cangaroo
  class PushJob < Job
    include Cangaroo::ClassConfiguration

    class_configuration :connection
    class_configuration :path, ''
    class_configuration :parameters, {}
    class_configuration :process_response, true

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

      return unless self.process_response

      PerformFlow.call(
        source_connection: destination_connection,
        json_body: response.to_json,
        jobs: Rails.configuration.cangaroo.jobs
      )
    end

    def destination_connection
      @connection ||= Cangaroo::Connection.find_by!(name: connection)
    end
  end
end
