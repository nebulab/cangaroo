require 'rails_helper'

module Cangaroo
  RSpec.describe Job, type: :job do
    let(:job) { Cangaroo::Job.new(item) }
    let(:item) { build(:cangaroo_item)}

    describe :perform? do
      it { expect{job.perform?(item)}.to raise_error(NotImplementedError) }
    end
  end
end
