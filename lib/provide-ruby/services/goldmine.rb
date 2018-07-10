module Provide
  module Services
    class Goldmine < Provide::ApiClient

      def initialize(scheme = 'http', host, token)
        @scheme = scheme
        @host = host
        @token = token
      end

      def bridges(params = nil)
        parse client.get 'bridges', (params || {})
      end

      def bridge_details(bridge_id)
        parse client.get "bridges/#{bridge_id}"
      end

      def create_bridge(params)
        parse client.post 'bridges', params
      end
  
      def contracts(params = nil)
        parse client.get 'contracts', (params || {})
      end

      def contract_details(contract_id)
        parse client.get "contracts/#{contract_id}"
      end
  
      def create_contract(params)
        parse client.post 'contracts', params
      end
  
      def execute_contract(contract_id, params)
        parse client.post "contracts/#{contract_id}/execute", params
      end

      def networks(params = nil)
        parse client.get 'networks', (params || {})
      end
  
      def create_network(params)
        parse client.post 'networks', params
      end

      def update_network(network_id, params)
        parse client.put "networks/#{network_id}", params
      end

      def network_details(network_id)
        parse client.get "networks/#{network_id}"
      end

      def network_status(network_id)
        parse client.get "networks/#{network_id}/status"
      end

      def network_nodes(network_id, params = nil)
        parse client.get "networks/#{network_id}/nodes", (params || {})
      end
  
      def create_network_node(network_id, params)
        parse client.post "networks/#{network_id}/nodes", params
      end
  
      def network_node_details(network_id, node_id)
        parse client.get "networks/#{network_id}/nodes/#{node_id}"
      end
  
      def network_node_logs(network_id, node_id)
        parse client.get "networks/#{network_id}/nodes/#{node_id}/logs"
      end

      def destroy_network_node(network_id, node_id)
        parse client.delete "networks/#{network_id}/nodes/#{node_id}"
      end

      def oracles(params = nil)
        parse client.get 'oracles', (params || {})
      end

      def oracle_details(oracle_id)
        parse client.get "oracles/#{oracle_id}"
      end

      def create_oracle(params)
        parse client.post 'oracles', params
      end

      def prices(params = nil)
        parse client.get 'prices', (params || {})
      end

      def tokens(params = nil)
        parse client.get 'tokens', (params || {})
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
