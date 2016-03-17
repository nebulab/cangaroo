module Cangaroo
  class RunPolls
    include Interactor

    def call
      poll_execution_time = DateTime.now

      context.jobs.each do |poll_job|
        last_poll_timestamp = Cangaroo::PollTimestamp.for_class(poll_job)
        last_poll_date = last_poll_timestamp.value

        if last_poll_date.nil? || poll_execution_time.to_i - last_poll_date.to_i > poll_job.frequency
          poll_job.new(last_poll: last_poll_date.to_i).enqueue
        end
      end
    end

  end
end
