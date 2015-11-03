module Cangaroo
  class HandleRequest
    prepend SimpleCommand

    def initialize(payload, key, token)
      @key = key
      @token = token
      @payload = payload
    end

    def call
      unless connection.present? && valid_json? && items.any?
        return false
      end

      items
    end

    def connection
      @connection ||= run_command(AuthenticateConnection, @key, @token)
    end

    def valid_json?
      return false unless connection.present?

      @valid_json ||= run_command ValidateJsonSchema, @payload
    end

    def items
      return {} unless connection.present? && valid_json?
      return @items if @items

      items = run_command CreateOrUpdateItems, @payload, connection
      @items = Hash.new(0)

      items.each do |item|
        @items[item.item_type] += 1
      end

      @items
    end

    private

    def run_command(command, *args)
      cmd = command.call *args

      errors.add(:error, cmd.errors[:error].first) unless cmd.success?
      cmd.result
    end
  end
end
