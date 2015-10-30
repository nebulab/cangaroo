require 'rails_helper'

module Cangaroo
  RSpec.describe HandleRequest do
    let(:command) { HandleRequest.new(connection.key, connection.token, json_payload) }

    describe "call" do
      before do
        command.call
      end

      context "when success" do
        let(:json_payload) { load_fixture('json_payload_ok.json') }
        let(:connection) { create :cangaroo_connection }

        it "authenticates connection" do
          expect(command.authenticated?).to be true
        end

        it "validates json schema" do
          expect(command.valid_json?).to be true
        end

        it 'saves items' do
          expect(command.items).not_to be_empty
        end
      end

      context "when failure" do
        let(:json_payload) { load_fixture('json_payload_no_id.json') }
        let(:connection) { create :cangaroo_connection }

        it "authenticates connection" do
          expect(command.authenticated?).to be true
        end

        it "validates json schema" do
          expect(command.valid_json?).to be false
        end

        it 'saves items' do
          expect(command.items).to be_empty
        end
      end

    end
  end
end
