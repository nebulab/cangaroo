module Cangaroo
  module Webhook
    class Client
      include HTTParty

      format :json

      attr_accessor :connection, :path

      def initialize(connection, path)
        @connection = connection
        @path = path
      end

      def post(payload, request_id, parameters)
        request_body = body(payload, request_id, parameters).to_json

        request_options = {
          headers: headers,
          body: request_body
        }

        if Rails.configuration.cangaroo.basic_auth
          request_options.merge!(
            basic_auth: {
              username: connection.key,
              password: connection.token
            }
          )
        end

        req = self.class.post(url, request_options)

        if req.response.code == '200'
          req.parsed_response
        elsif req.response.code == '203'
          ''
        else
          fail Cangaroo::Webhook::Error, req.parsed_response['summary']
        end
      end

      private

      def url
        URI.parse(
          HTTParty.normalize_base_uri(connection.url)
        ).merge(path.to_s).to_s
      end

      def headers
        {
          'X_HUB_TOKEN' => connection.token || '',
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      end

      def body(payload, request_id, parameters)
        { request_id: request_id,
          parameters: connection.parameters.deep_merge(parameters)
        }.merge(payload)
      end
    end
  end
end
