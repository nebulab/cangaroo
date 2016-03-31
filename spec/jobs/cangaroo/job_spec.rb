require 'rails_helper'

module Cangaroo
  RSpec.describe Job, type: :job do
    class FakeJob < Cangaroo::Job
      connection :store
      path '/webhook_path'
      parameters(email: 'info@nebulab.it')
    end

    let(:job_class) { FakeJob }
    let(:destination_connection) { create(:cangaroo_connection) }
    let(:type) { 'orders' }
    let(:payload) { { id: 'O123' } }
    let(:connection_response) { parse_fixture('json_payload_connection_response.json') }

    let(:options) do
      { connection: destination_connection,
        type: type,
        payload: payload }
    end

    let(:client) do
      Cangaroo::Webhook::Client.new(destination_connection, '/webhook_path')
    end

    before do
      client.stub(:post).and_return(connection_response)
      allow(Cangaroo::Webhook::Client).to receive(:new).and_return(client)
      allow(Cangaroo::PerformFlow).to receive(:call)
    end

    describe '#perform' do
      let(:job) { job_class.new(options) }

      it 'instantiates a Cangaroo::Webhook::Client' do
        expect(Cangaroo::Webhook::Client).to receive(:new)
          .with(destination_connection, '/webhook_path')
          .and_return(client)
        job_class.perform_now(options)
      end

      it 'calls post on client' do
        job.perform
        expect(client).to have_received(:post)
          .with(job.transform, job.job_id, email: 'info@nebulab.it')
      end

      it 'restart the flow' do
        job.perform
        expect(Cangaroo::PerformFlow).to have_received(:call)
          .once
          .with(source_connection: destination_connection,
                json_body: connection_response.to_json,
                jobs: Rails.configuration.cangaroo.jobs)
      end

      context 'endpoint provides a empty response' do
        it 'should not restart the flow' do
          client.stub(:post).and_return('')

          job.perform

          expect(Cangaroo::PerformFlow).to_not have_received(:call)
        end
      end
    end

    describe '#perform?' do
      it { expect { job_class.new(options).perform? }.to raise_error(NotImplementedError) }
    end

    describe '#transform' do
      it { expect(job_class.new(options).transform).to eq('order' => payload) }
    end
  end
end
