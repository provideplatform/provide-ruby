module Provide
  module Services
    class Bookie < Provide::ApiClient

      def initialize(scheme = 'http', host, token)
        @scheme = scheme
        @host = host
        @token = token
      end

      def billing_accounts(params = nil)
        parse client.get 'billing_accounts', (params || {})
      end

      def billing_account_details(billing_account_id)
        parse client.get "billing_accounts/#{billing_account_id}"
      end

      def create_billing_account(params)
        parse client.post 'billing_accounts', params
      end

      def update_billing_account(billing_account_id, params)
        parse client.put "billing_accounts/#{billing_account_id}", params
      end

      def connect(params = nil)
        parse client.get 'connect', (params || {})
      end

      def create_connection(params)
        parse client.post 'connect', params
      end

      def payment_hubs(params = nil)
        parse client.get 'payment_hubs', (params || {})
      end

      def payment_hub_details(payment_hub_id)
        parse client.get "payment_hubs/#{payment_hub_id}"
      end

      def create_payment_hub(params)
        parse client.post 'payment_hubs', params
      end

      def delete_payment_hub(payment_hub_id)
        parse client.delete "payment_hubs/#{payment_hub_id}"
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
  
      def channels(params = nil)
        parse client.get 'channels', (params || {})
      end

      def channel_details(channel_id)
        parse client.get "channels/#{channel_id}"
      end

      def create_channel(params)
        parse client.post 'channels', params
      end
  
      def update_channel_state(channel_id, params)
        parse client.post "channels/#{channel_id}/states", params
      end

      def create_thread(channel_id, params)
        parse client.post "channels/#{channel_id}/threads", params
      end

      def update_thread_state(channel_id, thread_id, params)
        parse client.post "channels/#{channel_id}/threads/#{thread_id}/states", params
      end

      def network(params = nil)
        parse client.get 'network', (params || {})
      end

      def network_invite(params)
        parse client.post 'network', params
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
