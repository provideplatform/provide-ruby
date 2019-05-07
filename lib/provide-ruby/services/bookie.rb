module Provide
  module Services
    class Bookie < Provide::ApiClient

      def initialize(scheme = 'http', host, token)
        @scheme = scheme
        @host = host
        @token = token
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

      def create_channel(params)
        parse client.post 'channels', params
      end
  
      def update_channel(channel_id, params)
        parse client.put "channels/#{channel_id}", params
      end
  
      def channels(params = nil)
        parse client.get 'channels', (params || {})
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
