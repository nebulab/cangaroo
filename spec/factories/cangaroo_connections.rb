FactoryGirl.define do
  factory :cangaroo_connection, class: 'Cangaroo::Connection' do
    name :store
    url 'www.store.com'
    parameters { { first: 'first', second: 'second' } }
    key '1e4e888ac66f8dd41e00c5a7ac36a32a9950d271'
    token '8d49cddb4291562808bfca1bee8a9f7cf947a987'
  end
end
