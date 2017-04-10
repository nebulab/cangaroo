class FakeJob < Cangaroo::Job
  include Cangaroo::LoggerHelper

  connection :store
  path '/webhook_path'
  parameters(email: 'info@nebulab.it')
end
