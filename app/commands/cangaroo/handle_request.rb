module Cangaroo
  class HandleRequest
    prepend SimpleCommand

    def initialize(key, token, payload)
      @valid_payload = validate_json_payload payload
      @connection = authenticate_connection(key, token)
      @items = save_items(payload)
    end

    def call
      unless authenticated? && valid_json?
        return false
      end


    end

    def items
      @items
    end

    def authenticated?
      @connection.present?
    end

    def valid_json?
      @valid_payload
    end

    private

    def save_items(payload)
      return [] unless valid_json?

      saved_items = CreateOrUpdateItems.call payload
      unless saved_items.success?
        errors.add :error, saved_items.errors[:item_errors]
        return []
      end
      saved_items.result
    end

    def authenticate_connection(key, token)
      authentication = AuthenticateConnection.call key, token

      unless authentication.success?
        errors.add :error, @authentication.errors[:authentication]
        return nil
      end
      authentication.result
    end

    def validate_json_payload(payload)
      json_validation = ValidateJsonSchema.call payload

      unless json_validation.success?
        errors.add :error, json_validation.errors[:schema_error]
        return false
      end
      true
    end
  end
end
