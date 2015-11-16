module Cangaroo
  class CountJsonObject
    include Interactor

    before :prepare_context

    def call
      context.object_count = context.data.inject({}) do |o, (k, v)|
        o[k] = v.size
        o
      end
    end

    private

    def prepare_context
      context.data = JSON.parse(context.json_body)
    end
  end
end
