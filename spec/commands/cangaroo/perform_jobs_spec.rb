require 'rails_helper'

module Cangaroo
  RSpec.describe PerformJobs do
    let(:command) { PerformJobs.new(item, [job_a, job_b]) }
    let(:item) { create(:cangaroo_item) }

    let(:job_a) { double(:job_a, { perform?: true, enqueue: nil }) }
    let(:job_b) { double(:job_b, { perform?: false, enqueue: nil }) }

    describe '#call' do

      before { command.call }

      it 'enqueues only cangaroo jobs that can perform' do
        expect(job_a).to have_received(:enqueue)
        expect(job_b).to_not have_received(:enqueue)
      end
    end
  end
end
