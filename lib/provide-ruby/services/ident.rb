module Provide
  module Services
    class Ident < Provide::ApiClient

      def initialize(scheme = 'http', host)
        @scheme = scheme
        @host = host
      end

      def create_application(params)
        parse client.post 'applications', params
      end

      def applications
        parse client.get 'applications'
      end

      def authenticate(params)
        parse client.post 'authenticate', params
      end

      def tokens(params)
        parse client.get 'tokens', params
      end

      def delete_token(token_id)
        parse client.delete("tokens/#{token_id}")
      end

      def create_user(params)
        parse client.post 'users', params
      end

      def users
        parse client.get 'users'
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
