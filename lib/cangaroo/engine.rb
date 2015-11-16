module Cangaroo
  class Engine < ::Rails::Engine
    isolate_namespace Cangaroo

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    config.before_configuration do
      Rails.configuration.cangaroo = ActiveSupport::OrderedOptions.new
      Rails.configuration.cangaroo.jobs = []
    end
  end
end
