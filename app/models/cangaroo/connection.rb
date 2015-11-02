module Cangaroo
  class Connection < ActiveRecord::Base
    serialize :parameters

    validates :name, :url, :key, :token, presence: true
    validates :name, :url, :key, :token, uniqueness: true
  end
end
