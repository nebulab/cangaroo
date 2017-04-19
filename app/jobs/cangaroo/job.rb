module Cangaroo
  class Job < ActiveJob::Base
    include Cangaroo::LoggerHelper

    queue_as :cangaroo

    attr_reader :source_connection, :type, :payload

    def perform(source_connection:, type:, payload:)
      @source_connection = source_connection
      @type = type
      @payload = payload
    end

    def perform?
      fail NotImplementedError
    end
  end
end
