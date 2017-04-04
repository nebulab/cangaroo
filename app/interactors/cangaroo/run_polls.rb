module Cangaroo
  class RunPolls
    include Interactor

    def call
      context.jobs.each do |poll_job|
        poll_job.new.enqueue
      end
    end
  end
end
