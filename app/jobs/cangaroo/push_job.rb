module Cangaroo
  class PushJob < BaseJob
    def perform(source_connection:, type:, payload:)
      super
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
