require 'rails_helper'

class CustomLogger
  def log(_message); end

  def unknown(_message, _opts = {}); end

  def debug(_message, _opts = {}); end

  def info(_message, _opts = {}); end

  def warn(_message, _opts = {}); end

  def error(_message, _opts = {}); end
end

describe Cangaroo::Logger do
  let(:cangaroo_logger) { Cangaroo::Logger.send(:new) }
  before { Rails.configuration.cangaroo.logger = logger }

  describe '#logger' do
    subject { cangaroo_logger.logger }

    context 'when Rails.configuration.cangaroo.logger is set' do
      let(:logger) { CustomLogger.new }

      it { is_expected.to eq(logger) }
    end

    context 'when Rails.configuration.cangaroo.logger is not set' do
      let(:logger) { nil }

      it { is_expected.to eq(Rails.logger) }
    end
  end

  context 'log methods' do
    let(:message) { 'message' }
    let(:opts) { { opt1: 1, opt2: 2 } }

    describe '#log' do
      after { cangaroo_logger.log(message, opts) }

      context 'when logger can receive given parameters' do
        let(:logger) { nil }

        it 'calls the logger log method with the given params' do
          expect(Rails.logger).to receive(:log).with(message, opts)
        end
      end

      context 'when logger can not receive given parameters' do
        let(:logger) { CustomLogger.new }

        it 'calls the logger log method with an array of message and params' do
          expect(logger).to receive(:log).with([message, opts])
        end
      end
    end

    %i(unknown debug info warn error).each do |log_method|
      describe "##{log_method}" do
        after { cangaroo_logger.send(log_method, message, opts) }

        context 'when logger can receive given parameters' do
          let(:logger) { CustomLogger.new }

          it "calls the logger #{log_method} method with the given params" do
            expect(logger).to receive(log_method).with(message, opts)
          end
        end

        context 'when logger can not receive given parameters' do
          let(:logger) { nil }

          it "calls the logger #{log_method} method with an array of message and params" do
            expect(Rails.logger).to receive(log_method).with([message, opts])
          end
        end
      end
    end
  end
end
