module Cangaroo
  class PerformJobs
    include Interactor

    def call
      context.json_body.each do |type, payloads|
        payloads.each { |payload| enqueue_jobs(type, payload) }
      end
    end

    private

    def enqueue_jobs(type, payload)
      initialize_jobs(type, payload).select(&:perform?).each(&:enqueue)
    end

    def initialize_jobs(type, payload)
      context.jobs.map do |klass|
        klass.new(
          source_connection: context.source_connection,
          type: type,
          payload: payload
        )
      end
    end
  end
end
