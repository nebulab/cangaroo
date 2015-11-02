require 'rails_helper'

module Cangaroo
  RSpec.describe PerformJobs do
    class JobA < Job ; end
    class JobB < Job ; end

    let(:command) { PerformJobs.new(item, [JobA, JobB]) }
    let(:item) { create(:cangaroo_item) }
    let(:job_a) { JobA.new item  }
    let(:job_b) { JobB.new item  }

    before do
      allow(JobA).to receive(:new).and_return(job_a)
      allow(JobB).to receive(:new).and_return(job_b)
      allow(job_a).to receive_messages(perform?: true, enqueue: nil)
      allow(job_b).to receive_messages(perform?: false, enqueue: nil)
    end

    describe '#call' do
      before { command.call }

      it 'enqueues only cangaroo jobs that can perform' do
        expect(job_a).to have_received(:enqueue)
        expect(job_b).to_not have_received(:enqueue)
      end

      it 'returns the enqueued jobs' do
        expect(command.result).to include(job_a)
        expect(command.result).to_not include(job_b)
      end
    end
  end
end
