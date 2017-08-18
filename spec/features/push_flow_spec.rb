require 'rails_helper'
require 'securerandom'

RSpec.describe 'Push flow' do
  let(:store_payload) { load_fixture('json_payload_ok.json') }
  let(:payed_order) { JSON.parse(store_payload)['orders'].last }
  let(:store) { Cangaroo::Connection.find_by(name: 'store') }
  let(:headers) {
    { 'Content-Type' => 'application/json',
      'X-Hub-Store' => store.key,
      'X-Hub-Access-Token' => store.token }
  }

  let!(:erp_api) {
    stub_api(job: Cangaroo::ErpJob,
             request_body: { order: { id: payed_order['id'], state: payed_order['state'] } },
             response_body: {
               'summary' => "Successfully updated order for #{payed_order['id']}",
               'orders' => [{ id: payed_order['id'], state: 'confirmed' }]
             })
  }

  let!(:update_order_store_api) {
    stub_api(job: Cangaroo::StoreJob, request_body: { order: { id: payed_order['id'], state: anything } })
  }

  let!(:confirm_mail_api) {
    stub_api(job: Cangaroo::ConfirmOrderMailJob, request_body: { order: { id: payed_order['id'], state: 'confirmed' } })
  }

  let!(:warehouse_api) {
    stub_api(job: Cangaroo::WarehouseJob,
             request_body: { order: { id: payed_order['id'], state: 'confirmed' } },
             response_body: {
               'summary' => "Successfully shipped order #{payed_order['id']}",
               'orders' => [{ id: payed_order['id'], state: 'shipped' }]
             })
  }

  let!(:shipped_mail_api) {
    stub_api(job: Cangaroo::ShippedOrderMailJob, request_body: { order: { id: payed_order['id'], state: 'shipped' } })
  }

  before do
    Rails.configuration.cangaroo.jobs = [Cangaroo::ErpJob,
                                         Cangaroo::StoreJob,
                                         Cangaroo::ConfirmOrderMailJob,
                                         Cangaroo::WarehouseJob,
                                         Cangaroo::ShippedOrderMailJob]

    post endpoint_index_path, params: store_payload, headers: headers
  end

  describe 'when new order in state cart coming from store' do
    it 'calls the erp api that responds with order in confirmed state' do
      expect(erp_api).to have_been_requested
    end

    context 'then' do
      it 'calls mail api to send confirmation email to user' do
        expect(confirm_mail_api).to have_been_requested
      end

      it 'calls warehouse to send the package and responds with order in shipped state' do
        expect(warehouse_api).to have_been_requested
      end

      context 'then' do
        it 'calls mail api to send shipped email to user' do
          expect(shipped_mail_api).to have_been_requested
        end
      end
    end

    it 'calls the store api to update the order state twice' do
      expect(update_order_store_api).to have_been_requested.twice
    end
  end
end
