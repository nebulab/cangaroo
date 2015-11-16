require 'rails_helper'

describe Cangaroo::CountJsonObject do
  subject(:context) { Cangaroo::CountJsonObject.call(json_body: json_body) }

  let(:json_body) { load_fixture('json_payload_ok.json') }

  describe '.call' do
    it 'provides the object_count' do
      expect(context.object_count).to eq({ 'orders' => 2, 'shipments' => 2 })
    end

    it 'succeeds' do
      expect(context).to be_a_success
    end
  end
end
