require 'rails_helper'

class PollJobA < Cangaroo::PollJob; end
class PollJobB < Cangaroo::PollJob; end

describe Cangaroo::RunPolls do
  let(:connection) { create(:cangaroo_connection) }

  let(:job_a) { double('job_a', enqueue: nil) }
  let(:job_b) { double('job_b', enqueue: nil) }

  before do
    allow(PollJobA).to receive(:new).with(any_args).and_return(job_a)
    allow(PollJobB).to receive(:new).with(any_args).and_return(job_b)

    allow(PollJobA).to receive(:connection).and_return(connection.name)
    allow(PollJobB).to receive(:connection).and_return(connection.name)
  end

  describe '.call' do
    it 'runs a poll if one has never been run' do
      Cangaroo::RunPolls.call(jobs: [PollJobA, PollJobB])

      expect(PollJobA).to have_received(:new).exactly(1).times
      expect(PollJobB).to have_received(:new).exactly(1).times
    end

    it 'runs a poll if the poll frequency delta is reached' do
      last_poll_a = Cangaroo::PollTimestamp.for_class(PollJobA)
      last_poll_a.value = DateTime.now - PollJobA.frequency - 1.second
      last_poll_a.save

      last_poll_b = Cangaroo::PollTimestamp.for_class(PollJobB)
      last_poll_b.value = DateTime.now - PollJobB.frequency - 1.second
      last_poll_b.save

      Cangaroo::RunPolls.call(jobs: [PollJobA, PollJobB])

      expect(PollJobA).to have_received(:new).exactly(1).times
      expect(PollJobB).to have_received(:new).exactly(1).times
    end

    it 'does not run a poll if the time passed is less than the frequency' do
      last_poll_a = Cangaroo::PollTimestamp.for_class(PollJobA)
      last_poll_a.value = DateTime.now - PollJobA.frequency + 1.second
      last_poll_a.save

      last_poll_b = Cangaroo::PollTimestamp.for_class(PollJobB)
      last_poll_b.value = DateTime.now - PollJobB.frequency + 1.second
      last_poll_b.save

      Cangaroo::RunPolls.call(jobs: [PollJobA, PollJobB])

      expect(PollJobA).to_not have_received(:new)
      expect(PollJobB).to_not have_received(:new)
    end
  end
end
