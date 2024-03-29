# Copyright 2017-2022 Provide Technologies Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Provide
  module Services
    class NChain < Provide::ApiClient

      def initialize(scheme = 'http', host, token)
        @scheme = scheme
        @host = host
        @token = token
      end

      def accounts(params = nil)
        parse client.get 'accounts', (params || {})
      end

      def account_details(account_id)
        parse client.get "accounts/#{account_id}"
      end

      def account_balance(account_id, token_id)
        parse client.get "accounts/#{account_id}/balances/#{token_id}"
      end

      def create_account(params)
        parse client.post 'accounts', params
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

      def connectors(params = nil)
        parse client.get 'connectors', (params || {})
      end

      def connector_details(connector_id)
        parse client.get "connectors/#{connector_id}"
      end

      def connector_load_balancers(connector_id, params = nil)
        parse client.get "connectors/#{connector_id}/load_balancers", (params || {})
      end

      def connector_nodes(connector_id, params = nil)
        parse client.get "connectors/#{connector_id}/nodes", (params || {})
      end

      def create_connector(params)
        parse client.post 'connectors', params
      end

      def destroy_connector(connector_id)
        parse client.delete "connectors/#{connector_id}"
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

      def network_accounts(network_id, params)
        parse client.get "networks/#{network_id}/accounts", params
      end

      def network_blocks(network_id, params)
        parse client.get "networks/#{network_id}/blocks", params
      end

      def network_bridges(network_id, params)
        parse client.get "networks/#{network_id}/bridges", params
      end

      def network_connectors(network_id, params)
        parse client.get "networks/#{network_id}/connectors", params
      end

      def network_contracts(network_id, params)
        parse client.get "networks/#{network_id}/contracts", params
      end

      def network_contract_details(network_id, contract_id)
        parse client.get "networks/#{network_id}/contracts/#{contract_id}"
      end

      def network_load_balancers(network_id, params)
        parse client.get "networks/#{network_id}/load_balancers", params
      end

      def update_network_load_balancers(network_id, load_balancer_id, params)
        parse client.put "networks/#{network_id}/load_balancers/#{load_balancer_id}", params
      end

      def network_oracles(network_id, params)
        parse client.get "networks/#{network_id}/oracles", params
      end

      def network_tokens(network_id, params)
        parse client.get "networks/#{network_id}/tokens", params
      end

      def network_transactions(network_id, params)
        parse client.get "networks/#{network_id}/transactions", params
      end

      def network_transaction_details(network_id, transaction_id)
        parse client.get "networks/#{network_id}/transactions/#{transaction_id}"
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

      def network_node_logs(network_id, node_id, params = nil)
        parse client.get "networks/#{network_id}/nodes/#{node_id}/logs", (params || {})
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
