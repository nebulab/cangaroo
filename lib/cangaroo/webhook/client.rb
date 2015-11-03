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
        req = self.class.post(url, {
          headers: headers,
          query: connection.parameters,
          body: body(payload, request_id, parameters).to_json
        })
        if req.response.code == '200'
          req.parsed_response
        else
          raise Cangaroo::Webhook::Error, req.parsed_response['summary']
        end
      end

      private

      def url
        URI.parse(HTTParty.normalize_base_uri(connection.url)).merge(self.path.to_s).to_s
      end

      def headers
        { 'X-Hub-Store' => connection.key, 'X-Hub-Token' => connection.token }
      end

      def body(payload, request_id, parameters)
        { request_id: request_id, parameters: parameters }.merge(payload)
      end
    end
  end
end
