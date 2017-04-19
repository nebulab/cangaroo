require 'rails_helper'

RSpec.describe Cangaroo::PollJob, type: :job do
  class FakePollJob < Cangaroo::PollJob
    connection :store
    path '/webhook_path'
    parameters(email: 'info@nebulab.it')
  end

  let(:job_class) { FakePollJob }
  let(:job) { job_class.new(last_poll: Time.now.to_i) }
  let(:successful_pull_payload) { parse_fixture('json_payload_ok.json') }

  before do
    create(:cangaroo_connection)
  end

  describe '#perform?' do
    before do
      allow_any_instance_of(Cangaroo::Webhook::Client).to receive(:post)
        .and_return(successful_pull_payload)

      allow(Cangaroo::HandleRequest).to receive(:call).
        and_return(double(success?: true))
    end

    it 'runs a poll if one has never been run' do
      expect(FakePollJob.new.perform?(DateTime.now)).to eq(true)
    end

    it 'runs a poll if the poll frequency delta is reached' do
      last_poll = Cangaroo::PollTimestamp.for_class(FakePollJob)
      last_poll.value = DateTime.now - FakePollJob.frequency - 1.second
      last_poll.save

      expect(FakePollJob.new.perform?(DateTime.now)).to eq(true)
    end

    it 'does not run a poll if the time passed is less than the frequency' do
      last_poll = Cangaroo::PollTimestamp.for_class(FakePollJob)
      last_poll.value = DateTime.now - FakePollJob.frequency + 1.second
      last_poll.save

      expect(FakePollJob.new.perform?(DateTime.now)).to eq(false)
    end
  end

  describe '#perform' do
    context 'pull is successful' do
      before do
        allow(Cangaroo::HandleRequest).to receive(:call).
          and_return(double(success?: true))

        allow_any_instance_of(Cangaroo::PollJob).to receive(:perform?)
          .and_return(true)
      end

      it 'updates the poll timestamp' do
        Cangaroo::Webhook::Client.any_instance.stub(:post).and_return(successful_pull_payload)

        job.perform

        last_poll_timestamp = Cangaroo::PollTimestamp.for_class(FakePollJob)
        expect(last_poll_timestamp.job).to eq(job.class.to_s)
        expect(last_poll_timestamp.connection.name).to eq(job.class.connection.to_s)
        expect(last_poll_timestamp.value).to be <= DateTime.now
      end

      it 'handles a empty response' do
        Cangaroo::Webhook::Client.any_instance.stub(:post).and_return('')

        job.perform
      end

      it 'handles a response with a empty array' do
        Cangaroo::Webhook::Client.any_instance.stub(:post).and_return(
          parse_fixture('json_payload_empty.json')
        )

        job.perform
      end
    end

    context 'pull fails' do
      before do
        Cangaroo::Webhook::Client.any_instance.stub(:post).and_return(parse_fixture('json_payload_ok.json'))

        allow(Cangaroo::PerformFlow).to receive(:call).and_return(double(success?: false,
                                                                         message: 'bad failure'))
      end

      it 'does not update timestamp if pull fails' do
        expect { job.perform }.to raise_error(Cangaroo::Webhook::Error)

        expect(Cangaroo::PollTimestamp.for_class(FakePollJob).id).to be_nil
      end
    end
  end
end
