module Cangaroo
  class PushJob < BaseJob
    def perform(*)
      restart_flow(connection_request)
    end

    def perform?
      fail NotImplementedError
    end

    def transform
      { type.singularize => payload }
    end
  end
end
