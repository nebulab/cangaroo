require 'simplecov'
require 'pry-byebug'

SimpleCov.start 'rails' do
  add_group 'Commands', 'app/commands'
  add_filter 'lib/cangaroo/version'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../support/rails_app.rb', __FILE__)

puts "Testing against version #{ActiveRecord::VERSION::STRING}"

# Prevent database truncation if the environment is production
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

require 'spec_helper'
require 'rspec/rails'

# We manually require each file to make sure the files are required in the
# correct order and no exceptions come up because of wrong require order
%w(
  database_cleaner
  webmock
  shoulda_matchers
  factory_girl
  spec_helpers
).each { |path| require File.expand_path("../support/#{path}.rb", __FILE__) }

Dir[File.dirname(__FILE__) + '/support/jobs/*.rb'].each { |file| require file }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # reset config before each spec
  config.before(:each) do
    Rails.configuration.cangaroo.basic_auth = false
    Rails.configuration.cangaroo.jobs = []
    Rails.configuration.cangaroo.poll_job = []
    Rails.configuration.cangaroo.logger = nil
  end

  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end
