module Cangaroo
  class Job < ActiveJob::Base
    queue_as :cangaroo

    def perform?(item)
      raise NotImplementedError
    end
  end
end
