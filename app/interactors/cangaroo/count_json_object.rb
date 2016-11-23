module Cangaroo
  class CountJsonObject
    include Interactor
    include Cangaroo::Log

    before :prepare_context

    def call
      context.object_count = context.data.inject({}) do |o, (k, v)|
        o[k] = v.size
        o
      end

      logger.info 'total consumed payloads',
        guid: context.guid,
        count: context.object_count
    end

    private

    def prepare_context
      context.data = JSON.parse(context.json_body)
    end
  end
end
