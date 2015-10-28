module Cangaroo
  class AuthorizeConnection
    prepend SimpleCommand

    def initialize(key, token)
      @key = key
      @token = token
    end

    def call
      return connection if connection
      errors.add(:authentication, 'wrong credentials')
      false
    end

    private

    def connection
      @connection ||= Cangaroo::Connection.where(key: @key, token: @token).first
    end
  end
end
