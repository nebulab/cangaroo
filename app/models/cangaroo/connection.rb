module Cangaroo
  class Connection < ActiveRecord::Base
    serialize :parameters

    validates :name, :url, :key, :token, presence: true
    validates :name, :url, :key, :token, uniqueness: true

    def self.authenticate(key, token)
      where(key: key, token: token).first
    end
  end
end
