FactoryGirl.define do
  factory :cangaroo_item, :class => 'Cangaroo::Item' do
    item_type :orders
    item_id "R12345"
    payload { { id: 'R12345', amount: 5, discount: 10 } }
  end

end
