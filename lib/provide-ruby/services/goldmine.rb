module Provide
  module Services
    class Goldmine < Provide::ApiClient

      def initialize(scheme = 'http', host)
        @scheme = scheme
        @host = host
      end

      def networks
        parse client.get 'networks'
      end

      def prices
        parse client.get 'prices'
      end

      def tokens
        parse client.get 'tokens'
      end

      def create_token(params)
        parse client.post 'tokens', params
      end

      def create_transaction(params)
        parse client.post 'transactions', params
      end

      def transactions
        parse client.get 'transactions'
      end

      def wallets
        parse client.get 'wallets'
      end

      def create_wallet(params)
        parse client.post 'wallets', params
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
