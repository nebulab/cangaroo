require 'rails_helper'

describe Cangaroo::PerformFlow do
  subject { described_class.new }

  context 'organizes interactors' do
    subject { described_class.organized }

    let(:interactors) do
      [Cangaroo::ValidateJsonSchema,
       Cangaroo::CountJsonObject,
       Cangaroo::PerformJobs]
    end

    it { is_expected.to eql interactors }
  end
end
