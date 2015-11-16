module Cangaroo
  class AuthenticateConnection
    include Interactor

    before :prepare_context

    def call
      context.source_connection ||
        context.fail!(message: 'wrong credentials', error_code: 401)
    end

    private

    def prepare_context
      context.source_connection =
        Cangaroo::Connection.authenticate(context.key, context.token)
    end
  end
end
