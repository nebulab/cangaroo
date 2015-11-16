require 'rails_helper'

describe Cangaroo::ValidateJsonSchema do
  subject(:context) { Cangaroo::ValidateJsonSchema.call(json_body: json_body) }

  describe '.call' do
    context 'when json is well formatted' do
      let(:json_body) { JSON.parse(load_fixture('json_payload_ok.json')) }

      it 'succeeds' do
        expect(context).to be_a_success
      end
    end

    context 'when json is not well formatted' do
      describe 'with wrong main key' do
        let(:json_body) { JSON.parse(load_fixture('json_payload_wrong_key.json')) }

        it 'fails' do
          expect(context).to be_a_failure
        end

        it 'provides a failure message' do
          expect(context.message).to be_present
        end

        it 'provides a failure error code' do
          expect(context.error_code).to eq 500
        end
      end

      describe 'without an object id' do
        let(:json_body) { JSON.parse(load_fixture('json_payload_no_id.json')) }

        it 'fails' do
          expect(context).to be_a_failure
        end

        it 'provides a failure message' do
          expect(context.message).to be_present
        end

        it 'provides a failure error code' do
          expect(context.error_code).to eq 500
        end
      end
    end
  end
end
