module Cangaroo
  class HandleRequest
    prepend SimpleCommand

    def initialize(payload, connection)
      @key = connection.key
      @token = connection.token
      @connection = connection
      @payload = payload
    end

    def call
      unless authenticated? && valid_json? && items.any?
        return false
      end

      items
    end

    def authenticated?
      @authenticated ||= run_command(AuthenticateConnection, @key, @token).present?
    end

    def valid_json?
      return false unless authenticated?

      @valid_json ||= run_command ValidateJsonSchema, @payload
    end

    def items
      return [] unless authenticated? && valid_json?

      @items ||= run_command CreateOrUpdateItems, @payload, @connection
    end

    private

    def run_command(command, *args)
      cmd = command.call *args

      errors.add(:error, cmd.errors[:error]) unless cmd.success?
      cmd.result
    end
  end
end
