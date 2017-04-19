module Cangaroo
  class PollJob < BaseJob
    class_configuration :frequency, 1.day

    attr_reader :current_time

    def transform
      { last_poll: last_poll_timestamp.to_i }
    end

    def perform(*)
      @current_time = DateTime.now

      if !perform?(current_time)
        Cangaroo.logger.info 'skipping poll', job_tags
        return
      end

      restart_flow(connection_request)

      update_last_poll_timestamp
    end

    def perform?(execution_time)
      last_poll_timestamp.nil? ||
        execution_time.to_i - last_poll_timestamp.to_i > self.class.frequency
    end

    protected

    def update_last_poll_timestamp
      Cangaroo.logger.info 'updating last poll', job_tags(last_poll: current_time)

      last_job_poll = Cangaroo::PollTimestamp.for_class(self.class)
      last_job_poll.value = current_time
      last_job_poll.save!
    end

    def last_poll_timestamp
      @last_poll_timestamp ||= Cangaroo::PollTimestamp.for_class(self.class).value
    end
  end
end
