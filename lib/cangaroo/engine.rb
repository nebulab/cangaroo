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
      # Set the global default log level
      SemanticLogger.default_level = :trace
      SemanticLogger.add_appender(file_name: 'cangaroo.log', formatter: :color)

      Rails.configuration.cangaroo = ActiveSupport::OrderedOptions.new
      Rails.configuration.cangaroo.jobs = []
      Rails.configuration.cangaroo.poll_jobs = []
      Rails.configuration.cangaroo.basic_auth = false
    end
  end
end
