module Cangaroo
  class Job < ActiveJob::Base
    include Cangaroo::ClassConfiguration

    queue_as :cangaroo

    def perform(*)
      fail NotImplementedError
    end

    def perform?
      fail NotImplementedError
    end

    protected

    def source_connection
      arguments.first.fetch(:connection)
    end

    def type
      arguments.first.fetch(:type)
    end

    def payload
      arguments.first.fetch(:payload)
    end
  end
end
