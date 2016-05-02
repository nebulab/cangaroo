require 'webmock/rspec'

RSpec.configure do |config|
  # whitelist codeclimate.com so test coverage can be reported
  config.after(:suite) do
    WebMock.disable_net_connect!(allow: 'codeclimate.com')
  end
end
