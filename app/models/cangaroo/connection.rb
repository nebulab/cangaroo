module Cangaroo
  class Connection < ActiveRecord::Base
    serialize :parameters

    validates :name, :url, :token, presence: true, uniqueness: true
    validates :key, presence: true, uniqueness: true, if: -> { !Rails.configuration.cangaroo.basic_auth }

    after_initialize :set_default_parameters

    def self.authenticate(key, token)
      where(key: key, token: token).first
    end

    private

    def set_default_parameters
      self.parameters ||= {}
    end
  end
end
