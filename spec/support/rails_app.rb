require 'active_record/railtie'
require 'action_controller/railtie'
require 'active_job/railtie'
require 'action_dispatch/railtie'
require 'securerandom'

require 'cangaroo'

ENV['DATABASE_URL'] = 'postgresql://localhost/cangaroo_test?pool=5'

# Initialize our test app

class RailsApp < Rails::Application
  config.secret_key_base = SecureRandom.hex
  config.eager_load = false
end

ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json] if respond_to?(:wrap_parameters)
end

RailsApp.initialize!

RailsApp.routes.draw do
  mount Cangaroo::Engine => "/cangaroo"
end
