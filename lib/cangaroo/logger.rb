module Cangaroo
  class Logger
    include Singleton

    attr_reader :logger

    def initialize
      @logger = Rails.configuration.cangaroo.logger || Rails.logger
    end

    %i(log unknown debug info warn error).each do |log_method|
      define_method log_method do |*params|
        begin
          @logger.send(log_method, *params)
        rescue ArgumentError
          @logger.send(log_method, params)
        end
      end
    end
  end
end
