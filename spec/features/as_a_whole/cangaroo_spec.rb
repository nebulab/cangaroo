require 'rails_helper'

RSpec.describe 'Cangaroo', type: :request do
  class FakeJob < Cangaroo::Job
    connection :store
    path '/webhook_path'
    parameters(email: 'info@nebulab.it')

    def perform?(*)
      true
    end

    def transform
      # do nothing
      { type => payload }
    end
  end

  let(:job_class) { FakeJob }
  let(:job) do
    job_class.new(
      connection: connection,
      type: type,
      payload: json_payload
    )
  end
  let(:type) { 'orders' }
  let(:json_payload) do
    [
      {
        "id" => "O154085346",
        "status" => "complete",
        "email" => "user@example.com"
      }
    ]
  end
  let(:json) do
    {
      "#{type}" => json_payload
    }.to_json
  end

  let(:connection) { create(:cangaroo_connection) }

  before do
    Rails.configuration.cangaroo.jobs << FakeJob

    # Force Rails to create http requests with the same id
    allow(SecureRandom).to receive(:uuid).and_return(1234)

    allow_any_instance_of(Cangaroo::PerformJobs)
      .to receive(:initialize_jobs)
      .and_return(Array(job))

    expect(Cangaroo::Connection)
      .to receive(:authenticate)
      .and_return(connection)
  end

  context 'when a job transform does nothing' do
    it 'receives a request with a payload and generates a request with the same payload' do

      transformed_request_params = {
        headers: {
          "X_HUB_TOKEN"=>"8d49cddb4291562808bfca1bee8a9f7cf947a987",
          "Content-Type"=>"application/json",
          "Accept"=>"application/json"
        },
        body: "{\"request_id\":1234,\"parameters\":{\"first\":\"first\",\"second\":\"second\",\"email\":\"info@nebulab.it\"},\"#{type}\":#{json_payload.to_json}}"
      }

      headers = { "Content-Type" => "application/json" }

      expect(Cangaroo::Webhook::Client)
        .to receive(:post)
        .with('http://www.store.com/webhook_path', transformed_request_params)

      post "/cangaroo/endpoint", json, headers
    end
  end
end
