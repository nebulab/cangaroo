module Cangaroo::SpecHelpers
  def load_json(filename)
    JSON.parse(File.read(
      File.expand_path("../../fixtures/#{filename}.json", __FILE__)
    ))
  end
end

RSpec.configure do |config|
  config.include Cangaroo::SpecHelpers
end
