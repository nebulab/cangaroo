require 'securerandom'

FactoryGirl.define do
  factory :cangaroo_connection, class: 'Cangaroo::Connection' do
    name :store
    url 'www.store.com'
    parameters { { first: 'first', second: 'second' } }
    key { SecureRandom.hex }
    token { SecureRandom.hex }

    factory :store do
      parameters nil
    end

    factory :erp do
      parameters nil
      name :erp
      url 'www.erp.com'
    end

    factory :mail do
      parameters nil
      name :mail
      url 'www.mail.com'
    end

    factory :warehouse do
      parameters nil
      name :warehouse
      url 'www.warehouse.com'
    end
  end
end
