module Cangaroo
  class Logger
    include Singleton

    def initialize
      @logger = Rails.configuration.cangaroo.logger || Rails.logger
    end

    %i(debug info warn error).each do |log_method|
      define_method log_method do |msg, opts = {}|
        begin
          @logger.send(log_method, msg, opts)
        rescue
          @logger.send(:error, "#{msg}: #{opts}")
        end
      end
    end
  end
end
