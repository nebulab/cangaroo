module Cangaroo
  class CountJsonObject
    include Interactor

    def call
      context.object_count = context.json_body.each_with_object({}) do |(k, v), o|
        o[k] = v.size
      end

      Cangaroo.logger.info 'total consumed payloads', count: context.object_count
    end
  end
end
