module Cangaroo
  class PerformJobs
    prepend SimpleCommand

    def initialize(item, jobs)
      @item = item
      @jobs = jobs
    end

    def call
      @jobs.each { |job| job.enqueue if job.perform?(@item) }
    end
  end
end
