module Cangaroo
  class Job < ActiveJob::Base
    queue_as :cangaroo

    class_attribute :connection_name, :webhook_path, :webhook_parameters
    class << self
      def connection(name); self.connection_name = name; end
      def path(path); self.webhook_path = path; end
      def parameters(parameters); self.webhook_parameters = parameters; end
    end

    attr_accessor :item

    def initialize(*arguments)
      @item = arguments.first
      super
    end

    def perform(item)
      Cangaroo::Webhook::Client.new(connection, path)
        .post(transform(item), @job_id, parameters)
    end

    def perform?
      raise NotImplementedError
    end

    def transform(item)
      payload = {} 
      payload[item.item_type.singularize] = item.payload
      payload
    end

    private

    def connection
      @connection ||= Cangaroo::Connection.find_by!(name: connection_name)
    end

    def connection_name
      self.class.connection_name
    end

    def path
      self.class.webhook_path || ''
    end

    def parameters
      self.class.webhook_parameters || {}
    end
  end
end
