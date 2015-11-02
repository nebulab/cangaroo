module Cangaroo
  class Job < ActiveJob::Base
    queue_as :cangaroo

    cattr_accessor :connection_name, :path, :parameters
    attr_accessor :item

    class << self
      def connection_name(name)
        self.connection_name = name
      end

      def path(path)
        self.path = path || ''
      end

      def parameters(params)
        self.parameters = (params || {})
      end
    end

    def initialize(*arguments)
      @item = arguments.first
      super
    end

    def perform(item)
      Cangaroo::Webhook::Client.new(connection, path)
        .post(transform, @job_id, parameters)
    end

    def perform?
      raise NotImplementedError
    end

    def transform
      item.payload
    end

    private

    def connection
      @connection ||= Cangaroo::Connection.find_by!(name: connection_name)
    end
  end
end
