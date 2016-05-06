require 'rails_helper'

class PollJobA < Cangaroo::PollJob; end
class PollJobB < Cangaroo::PollJob; end

describe Cangaroo::RunPolls do
  let(:connection) { create(:cangaroo_connection) }

  # let(:job_a) { double('job_a', enqueue: nil) }
  # let(:job_b) { double('job_b', enqueue: nil) }

  it 'enques all polling jobs' do
    expect_any_instance_of(PollJobA).to receive(:enqueue).once
    expect_any_instance_of(PollJobB).to receive(:enqueue).once

    Cangaroo::RunPolls.call(jobs: [PollJobA, PollJobB])
  end
end
