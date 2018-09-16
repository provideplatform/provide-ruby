module Provide
  module Services
    class Ident < Provide::ApiClient

      def initialize(scheme = 'http', host, token)
        @scheme = scheme
        @host = host
        @token = token
      end

      def create_application(params = nil)
        parse client.post 'applications', (params || {})
      end
  
      def update_application(application_id, params)
        parse client.put "applications/#{application_id}", params
      end
  
      def applications(params = nil)
        parse client.get 'applications', (params || {})
      end

      def application(app_id)
        parse client.get "applications/#{app_id}"
      end

      def application_tokens(app_id, params = nil)
        parse client.get "applications/#{app_id}/tokens", (params || {})
      end

      def authenticate(params)
        parse client.post 'authenticate', params
      end

      def tokens(params = nil)
        parse client.get 'tokens', (params || {})
      end

      def token(token_id)
        parse client.get("tokens/#{token_id}")
      end

      def create_token(params)
        parse client.post 'tokens', params
      end

      def delete_token(token_id)
        parse client.delete("tokens/#{token_id}")
      end

      def create_user(params)
        parse client.post 'users', params
      end

      def users(params = nil)
        parse client.get 'users', (params || {})
      end

      def user(user_id)
        parse client.get "users/#{user_id}"
      end

      def update_user(user_id, params)
        parse client.put "users/#{user_id}", params
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
