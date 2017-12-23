module Provide
  module Services
    class Goldmine < Provide::ApiClient

      def initialize(scheme = 'http', host)
        @scheme = scheme
        @host = host
      end

      def prices
        parse client.get 'prices'
      end

      private

      def client
        @client ||= begin
          Provide::ApiClient.new(@scheme, @host, 'api/v1/')
        end
      end

      def parse(response)
        begin
          return response.code, JSON.parse(response.body)
        rescue
          raise Exception.new({
            :code => response.code,
          })
        end
      end
    end
  end
end
