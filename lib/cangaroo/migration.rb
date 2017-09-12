module Cangaroo
  module Migration
    def self.[](version)
      if Rails.gem_version >= Gem::Version.new('5.0')
        ActiveRecord::Migration[version]
      else
        ActiveRecord::Migration
      end
    end
  end
end
