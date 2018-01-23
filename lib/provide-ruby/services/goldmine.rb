module Provide
  module Services
    class Goldmine < Provide::ApiClient

      def initialize(scheme = 'http', host, token)
        @scheme = scheme
        @host = host
        @token = token
      end

      def contracts(params = nil)
        parse client.get 'contracts', (params || {})
      end

      def contract_details(contract_id)
        parse client.get "contracts/#{contract_id}"
      end

      def networks
        parse client.get 'networks'
      end

      def network_details(network_id)
        parse client.get "networks/#{network_id}"
      end

      def network_status(network_id)
        parse client.get "networks/#{network_id}/status"
      end

      def prices
        parse client.get 'prices'
      end

      def tokens
        parse client.get 'tokens'
      end

      def token_details(token_id)
        parse client.get "tokens/#{token_id}"
      end

      def create_token(params)
        parse client.post 'tokens', params
      end

      def create_transaction(params)
        parse client.post 'transactions', params
      end

      def transactions(params = nil)
        parse client.get 'transactions', (params || {})
      end

      def transaction_details(tx_id)
        parse client.get "transactions/#{tx_id}"
      end

      def wallet_balance(wallet_id, token_id)
        parse client.get "wallets/#{wallet_id}/balances/#{token_id}"
      end

      def wallets(params = nil)
        parse client.get 'wallets', (params || {})
      end

      def wallet_details(wallet_id)
        parse client.get "wallets/#{wallet_id}"
      end

      def create_wallet(params)
        parse client.post 'wallets', params
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
          return response.code, body
        rescue
          raise Exception.new({
            :code => response.code,
          })
        end
      end
    end
  end
end
