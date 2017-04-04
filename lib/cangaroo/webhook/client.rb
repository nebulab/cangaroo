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
          request_options[:basic_auth] = {
            username: connection.key,
            password: connection.token
          }
        end

        req = self.class.post(url, request_options)

        sanitized_response = sanitize_response(req)

        fail Cangaroo::Webhook::Error, sanitized_response unless %w(200 201 202 204).include?(req.response.code)
        sanitized_response
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
          parameters: connection.parameters.deep_merge(parameters) }.merge(payload)
      end

      def sanitize_response(request)
        if %w(200 201 202).include?(request.response.code)
          request.parsed_response
        elsif request.response.code == '204'
          ''
        else
          begin
            (request.parsed_response['summary'] || request.response.body)
          rescue
            request.response.body
          end
        end
      end
    end
  end
end
