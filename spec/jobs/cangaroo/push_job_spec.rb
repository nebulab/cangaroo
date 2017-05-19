require 'rails_helper'

module Cangaroo
  RSpec.describe PushJob, type: :job do
    let(:job_class) { FakePushJob }
    let(:destination_connection) { create(:cangaroo_connection) }
    let(:type) { 'orders' }
    let(:payload) { { id: 'O123' } }
    let(:connection_response) { parse_fixture('json_payload_connection_response.json') }

    let(:options) do
      { source_connection: destination_connection,
        type: type,
        payload: payload }
    end

    let(:client) do
      Cangaroo::Webhook::Client.new(destination_connection, '/webhook_path')
    end

    let(:fake_command) { double('fake perform flow command', success?: true) }

    let(:job) { job_class.new(options) }

    before do
      allow(client).to receive(:post).and_return(connection_response)
      allow(Cangaroo::Webhook::Client).to receive(:new).and_return(client)
      allow(Cangaroo::PerformFlow).to receive(:call).and_return(fake_command)
    end

    describe '#perform' do
      it 'instantiates a Cangaroo::Webhook::Client' do
        expect(Cangaroo::Webhook::Client).to receive(:new)
          .with(destination_connection, '/webhook_path')
          .and_return(client)
        job_class.perform_now(options)
      end

      it 'calls post on client' do
        job.perform_now
        expect(client).to have_received(:post)
          .with(job.transform, job.job_id, email: 'info@nebulab.it')
      end

      it 'restart the flow' do
        job.class.process_response(true)
        job.perform_now
        expect(Cangaroo::PerformFlow).to have_received(:call)
          .once
          .with(source_connection: destination_connection,
                json_body: connection_response,
                jobs: Rails.configuration.cangaroo.jobs)
      end

      it 'should not restart the flow when disabled' do
        job.class.process_response(false)

        job.perform_now

        expect(Cangaroo::PerformFlow).to_not have_received(:call)
      end

      context 'endpoint provides a empty response' do
        it 'should not restart the flow' do
          allow(client).to receive(:post).and_return('')

          job.perform_now

          expect(Cangaroo::PerformFlow).to_not have_received(:call)
        end
      end
    end

    describe '#perform?' do
      it { expect { job_class.new(options).perform? }.to raise_error(NotImplementedError) }
    end

    describe '#transform' do
      it 'return a single element hash with singularized type as key and payload as value' do
        job.perform_now
        expect(job.transform).to eq('order' => payload)
      end
    end
  end
end
