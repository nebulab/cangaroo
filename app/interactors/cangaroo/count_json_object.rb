module Cangaroo
  class CountJsonObject
    include Interactor

    before :prepare_context

    def call
      context.object_count = context.data.inject({}) do |object, (k, v)|
        object[k] = v.size
        object
      end
    end

    private

    def prepare_context
      context.data = JSON.parse(context.json_body)
    end
  end
end
