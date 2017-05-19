class FakePushJob < Cangaroo::PushJob
  connection :store
  path '/webhook_path'
  parameters(email: 'info@nebulab.it')
end
