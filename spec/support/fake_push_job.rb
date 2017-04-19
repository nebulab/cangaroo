class FakePushJob < Cangaroo::PushJob
  include Cangaroo::LoggerHelper

  connection :store
  path '/webhook_path'
  parameters(email: 'info@nebulab.it')
end
