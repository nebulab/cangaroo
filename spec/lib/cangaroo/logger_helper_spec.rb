require 'rails_helper'

describe Cangaroo::LoggerHelper do
  describe '#job_tags' do
    let(:job_class) { FakePushJob }
    let(:type) { 'orders' }
    let(:payload) { { id: 'O123' } }
    let(:options) do
      { connection: destination_connection,
        type: type,
        payload: payload }
    end
    let(:job) { job_class.new(options) }
    let!(:destination_connection) { create(:cangaroo_connection) }
    let(:extra_tags) { { tag1: 1, tag2: 2 } }

    it 'merges given tags with job class name, job_id and connection name' do
      expect(job.job_tags(extra_tags)).to eq(extra_tags.merge(job: 'FakePushJob', job_id: job.job_id, connection: destination_connection.name))
    end
  end
end
