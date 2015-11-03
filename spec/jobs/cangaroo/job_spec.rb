require 'rails_helper'

class FakeJob < Cangaroo::Job
  connection :store
  path '/webhook_path'
  parameters({ email: 'info@nebulab.it' })
end

module Cangaroo
  RSpec.describe Job, type: :job do

    let(:job_class) { FakeJob }

    let(:item) { create(:cangaroo_item) }
    let(:client) { Cangaroo::Webhook::Client.new(item.connection, '/webhook_path') }

    before do
      client.stub(:post)
      allow(Cangaroo::Webhook::Client).to receive(:new).and_return(client)
    end

    describe '#perform' do
      it 'instantiates a Cangaroo::Webhook::Client' do
        expect( Cangaroo::Webhook::Client ).to receive(:new)
          .with(item.connection, '/webhook_path')
          .and_return(client)
        FakeJob.perform_now(item)
      end

      it 'calls post on client' do
        job = job_class.new(item)
        job.perform_now
        expect(client).to have_received(:post).with(job.transform(item), job.job_id, { email: 'info@nebulab.it' })
      end
    end

    describe '#perform?' do
      it { expect{job_class.new(item).perform?}.to raise_error(NotImplementedError) }
    end

    describe '#transform' do
      it { expect(job_class.new.transform(item) ).to eq({ "order" => item.payload }) }
    end
  end
end
