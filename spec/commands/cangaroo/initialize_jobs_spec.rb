require 'rails_helper'

module Cangaroo
  RSpec.describe InitializeJobs do
    let(:command) { InitializeJobs.new(item) }
    let(:item) { create(:cangaroo_item) }

    let(:job_a) { double('job_a').as_null_object }
    let(:job_b) { double('job_b').as_null_object }

    let(:jobs) { [job_a, job_b] }

    before do
      Rails.application.config.cangaroo.jobs = jobs
    end

    describe '#call' do
      before { command.call }

      it 'returns and array' do
        expect(command.result).to be_a Array
      end

      it 'instantiates each cangaroo jobs with item' do
        expect(job_a).to have_received(:new).with(item)
        expect(job_b).to have_received(:new).with(item)
      end
    end
  end
end
