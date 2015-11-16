module Cangaroo
  class PerformJobs
    include Interactor

    def call
      data.each do |type, payloads|
        payloads.each { |payload| enqueue_jobs(type, payload) }
      end
    end

    private

    def data
      @data ||= JSON.parse(context.json_body)
    end

    def enqueue_jobs(type, payload)
      initialize_jobs(type, payload).select {|job| job.perform? }.each do |job|
        job.enqueue
      end
    end

    def initialize_jobs(type, payload)
      context.jobs.map do |klass|
        klass.new(
          connection: context.source_connection,
          type: type,
          payload: payload
        )
      end
    end
  end
end
