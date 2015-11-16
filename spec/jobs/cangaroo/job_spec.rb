require 'rails_helper'

module Cangaroo
  RSpec.describe Job, type: :job do

    class FakeJob < Cangaroo::Job
      connection :store
      path '/webhook_path'
      parameters({ email: 'info@nebulab.it' })
    end

    let(:job_class) { FakeJob }
    let(:source_connection) { create(:cangaroo_connection) }
    let(:type) { 'orders' }
    let(:payload) { { id: 'O123' } }

    let(:options) {
      { connection: source_connection,
        type: type,
        payload: payload }
    }

    let(:client) { Cangaroo::Webhook::Client.new(source_connection, '/webhook_path') }

    before do
      client.stub(:post)
      allow(Cangaroo::Webhook::Client).to receive(:new).and_return(client)
    end

    describe '#perform' do
      it 'instantiates a Cangaroo::Webhook::Client' do
        expect( Cangaroo::Webhook::Client ).to receive(:new)
          .with(source_connection, '/webhook_path')
          .and_return(client)
        FakeJob.perform_now(options)
      end

      it 'calls post on client' do
        job = job_class.new(options)
        job.perform
        expect(client).to have_received(:post).with(job.transform, job.job_id, { email: 'info@nebulab.it' })
      end
    end

    describe '#perform?' do
      it { expect{job_class.new(options).perform?}.to raise_error(NotImplementedError) }
    end

    describe '#transform' do
      it { expect(job_class.new(options).transform).to eq({ "order" => payload }) }
    end
  end
end
