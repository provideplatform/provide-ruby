module Provide
  module Services
    class Bookie < Provide::ApiClient

      def initialize(scheme = 'http', host, token)
        @scheme = scheme
        @host = host
        @token = token
      end

      def payment_methods(params = nil)
        parse client.get 'payment_methods', (params || {})
      end

      def create_payment_method(params)
        parse client.post 'payment_methods', params
      end

      def delete_payment_method(payment_method_id)
        parse client.delete "payment_methods/#{payment_method_id}"
      end

      private

      def client
        @client ||= begin
        Provide::ApiClient.new(@scheme, @host, 'api/v1/', @token)
        end
      end

      def parse(response)
        begin
        body = response.code == 204 ? nil : JSON.parse(response.body)
        return response.code, response.headers, body
        rescue
        raise Exception.new({
            :code => response.code,
        })
        end
      end
    end
  end
end
