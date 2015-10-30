require 'rails_helper'

module Cangaroo
  RSpec.describe PerformJobs do
    class JobA < Job
      def perform?(item); true; end
      def enqueue; nil; end
    end

    class JobB < Job
      def perform?(item); false; end
      def enqueue; nil; end
    end

    let(:command) { PerformJobs.new(item, [JobA, JobB]) }
    let(:item) { create(:cangaroo_item) }
    let(:job_a) { JobA.new item  }
    let(:job_b) { JobB.new item  }

    before do
      allow(JobA).to receive(:new).and_return(job_a)
      allow(JobB).to receive(:new).and_return(job_b)
    end

    describe '#call' do
      before { command.call }

      it 'enqueues only cangaroo jobs that can perform' do
        expect(command.result).to include(job_a)
        expect(command.result).to_not include(job_b)
      end
    end
  end
end
