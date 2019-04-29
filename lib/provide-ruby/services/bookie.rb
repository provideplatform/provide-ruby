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

      def create_channel(params)
        parse client.post 'channels', params
      end
  
      def update_channel(application_id, params)
        parse client.put "channels/#{application_id}", params
      end
  
      def channels
        parse client.get 'channels'
      end
  
      def network
        parse client.get 'network'
      end

      def network_invite(params)
        parse client.post 'network', params
      end
      
      private

      def client
        @client ||= begin
<<<<<<< HEAD
        Provide::ApiClient.new(@scheme, @host, 'api/v1/', @token)
=======
          Provide::ApiClient.new(@scheme, @host, 'api/v1/', @token)
>>>>>>> Add bookie service
        end
      end

      def parse(response)
        begin
<<<<<<< HEAD
        body = response.code == 204 ? nil : JSON.parse(response.body)
        return response.code, response.headers, body
        rescue
        raise Exception.new({
            :code => response.code,
        })
=======
          body = response.code == 204 ? nil : JSON.parse(response.body)
          return response.code, body
        rescue
          raise Exception.new({
            :code => response.code,
          })
>>>>>>> Add bookie service
        end
      end
    end
  end
end
