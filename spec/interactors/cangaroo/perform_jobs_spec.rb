require 'rails_helper'

class JobA < Cangaroo::Job; end
class JobB < Cangaroo::Job; end

describe Cangaroo::PerformJobs do
  subject(:context) do
    Cangaroo::PerformJobs.call(json_body: json_body,
                               jobs: [JobA, JobB],
                               source_connection: connection)
  end

  let(:connection) { create(:cangaroo_connection) }

  before do
    allow(JobA).to receive(:new).with(any_args).and_return(job_a)
    allow(JobB).to receive(:new).with(any_args).and_return(job_b)
  end

  describe '.call' do
    let(:job_a) { double('job_a', perform?: true, enqueue: nil) }
    let(:job_b) { double('job_b', perform?: false, enqueue: nil) }

    context 'payload with objects' do
      let(:json_body) { JSON.parse(load_fixture('json_payload_ok.json')) }

      it 'instantiates jobs' do
        context
        expect(JobA).to have_received(:new).exactly(4).times
        expect(JobB).to have_received(:new).exactly(4).times
      end

      it 'enqueues only cangaroo jobs that can perform' do
        context
        expect(job_a).to have_received(:enqueue).exactly(4).times
        expect(job_b).to_not have_received(:enqueue)
      end

      it 'succeeds' do
        expect(context).to be_a_success
      end
    end

    context 'payload with no objects' do
      let(:json_body) { JSON.parse(load_fixture('json_payload_empty.json')) }

      it 'succeeds' do
        context

        expect(context).to be_a_success
        expect(job_a).to_not have_received(:enqueue)
        expect(job_b).to_not have_received(:enqueue)
      end
    end
  end
end
