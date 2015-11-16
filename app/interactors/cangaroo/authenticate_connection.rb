module Cangaroo
  class AuthenticateConnection
    include Interactor

    def call
      if connection
        context.source_connection = connection
      else
        context.fail!(message: 'wrong credentials', error_code: 401)
      end
    end

    private

    def connection
      @connection ||= Cangaroo::Connection.authenticate(context.key, context.token)
    end
  end
end
