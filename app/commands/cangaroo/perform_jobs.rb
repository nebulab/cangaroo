module Cangaroo
  class PerformJobs
    prepend SimpleCommand

    def initialize(item, jobs)
      @item = item
      @jobs = jobs.map {|klass| klass.new(@item) }
    end

    def call
      @jobs.select {|job| job.perform? }.each {|job| job.enqueue }
    end
  end
end
