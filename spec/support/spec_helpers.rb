module Cangaroo
  module SpecHelpers
    def load_fixture(filename)
      File.read(File.expand_path("../../fixtures/#{filename}", __FILE__))
    end

    def parse_fixture(filename)
      JSON.parse(load_fixture(filename))
    end

    def stub_api(job:, request_body: {}, response_body: nil, response_status: 200)
      job_id = SecureRandom.uuid
      connection = Cangaroo::Connection.find_by(name: job.connection) || create(job.connection)

      allow_any_instance_of(job).to receive(:job_id).and_return(job_id)

      request_body = request_body.merge(
        request_id: job_id,
        parameters: connection.parameters || {}
      )

      response_body = response_body.merge('request_id' => job_id).to_json if response_body

      stub_request(:post, "#{connection.url}#{job.path}")
        .with(body: request_body,
              headers: { 'Accept': 'application/json',
                         'Content-Type': 'application/json',
                         'X-Hub-Token': connection.token })
        .to_return(body: response_body, status: response_status)
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Rails::RequestExampleGroup, type: :feature
  config.include Cangaroo::SpecHelpers
  config.include Cangaroo::Engine.routes.url_helpers
end
