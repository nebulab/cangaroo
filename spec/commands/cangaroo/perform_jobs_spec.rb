require 'rails_helper'

module Cangaroo
  RSpec.describe PerformJobs do
    class JobA < Job; end

    class JobB < Job; end

    let(:command) { PerformJobs.new(item, [JobA, JobB]) }
    let(:item) { create(:cangaroo_item) }
    let(:job_a) { JobA.new item  }
    let(:job_b) { JobB.new item  }

    before do
      ActiveJob::Base.queue_adapter = :test
      allow(JobA).to receive(:new).and_return(job_a)
      allow(JobB).to receive(:new).and_return(job_b)
      allow(job_a).to receive_messages(perform?: true, perform: nil)
      allow(job_b).to receive_messages(perform?: false, perform: nil)
    end

    describe '#call' do
      before { command.call }

      it 'enqueues only cangaroo jobs that can perform' do
        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to eq 1
      end

      it 'returns the enqueued jobs' do
        expect(command.result).to include(job_a)
        expect(command.result).to_not include(job_b)
      end
    end
  end
end
