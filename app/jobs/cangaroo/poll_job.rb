module Cangaroo
  class PollJob < ActiveJob::Base
    include Cangaroo::Log
    include SemanticLogger::Loggable
    include Cangaroo::ClassConfiguration

    queue_as :cangaroo

    class_configuration :connection
    class_configuration :frequency, 1.day
    class_configuration :path, ''
    class_configuration :parameters, {}

    def perform(*)
      current_time = DateTime.now

      if !perform?(current_time)
        logger.info 'skipping poll'
        return
      end

      logger.info 'initiating poll', last_poll: last_poll_timestamp.to_i

      response = Cangaroo::Webhook::Client.new(destination_connection, path)
        .post({ last_poll: last_poll_timestamp.to_i }, @job_id, parameters)

      logger.info 'processing poll results'

      command = HandleRequest.call(
        key: destination_connection.key,
        token: destination_connection.token,
        json_body: response.to_json,
        jobs: Rails.configuration.cangaroo.jobs
      )

      if !command.success?
        fail Cangaroo::Webhook::Error, command.message
      end

      logger.info 'updating last poll', last_poll: current_time

      last_job_poll = Cangaroo::PollTimestamp.for_class(self.class)
      last_job_poll.value = current_time
      last_job_poll.save!
    end

    def perform?(execution_time)
      last_poll_timestamp.nil? ||
      execution_time.to_i - last_poll_timestamp.to_i > self.class.frequency
    end

    protected

      def last_poll_timestamp
        @last_poll_timestamp ||= Cangaroo::PollTimestamp.for_class(self.class).value
      end

      def destination_connection
        @connection ||= Cangaroo::Connection.find_by!(name: connection)
      end

  end
end
