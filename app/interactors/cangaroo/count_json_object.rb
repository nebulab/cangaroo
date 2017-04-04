module Cangaroo
  class CountJsonObject
    include Cangaroo::Log
    include Interactor

    before :prepare_context

    def call
      context.object_count = context.data.each_with_object({}) do |(k, v), o|
        o[k] = v.size
      end

      log.info 'total consumed payloads', count: context.object_count
    end

    private

    def prepare_context
      context.data = JSON.parse(context.json_body)
    end
  end
end
