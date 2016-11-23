module Cangaroo
  class AuthenticateConnection
    include Interactor
    include Cangaroo::Log

    before :prepare_context

    def call
      if context.source_connection
        logger.info('authentication success',
                    guid: context.guid,
                    source_connection: {
                      id: context.source_connection.id,
                      name: context.source_connection.name
                    })
      else
        logger.info('authentication failed', guid: context.guid)
        context.fail!(message: 'wrong credentials', error_code: 401)
      end
    end

    private

    def prepare_context
      context.source_connection =
        Cangaroo::Connection.authenticate(context.key, context.token)
    end
  end
end
