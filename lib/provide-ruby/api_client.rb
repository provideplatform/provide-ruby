require 'typhoeus'

API_SCHEME = 'https'
API_HOST = 'provide.services'
API_USER_AGENT = 'provide-ruby api'
API_MAX_ATTEMPTS = 5

module Provide
  class ApiClient
    class << self
      def base_url
        "#{API_SCHEME}://#{API_HOST}"
      end
    end

    def initialize(token, secret)
      @token = token
      @secret = secret
    end

    def get(uri, params = { })
      send_request(:get, uri, params)
    end

    def post(uri, params = { })
      send_request(:post, uri, params)
    end

    def put(uri, params = { })
      send_request(:put, uri, params)
    end

    def delete(uri, params = { })
      send_request(:delete, uri, params)
    end

    def send_request(method, uri, params)
      attempts = 0

      begin
        params = [:post, :put, :patch].include?(method.to_s.downcase.to_sym) ? { body: JSON.dump(params) } : { params: params }
        headers = api_request_headers
        headers['Content-Type'] = 'application/json' if [:post, :put, :patch].include?(method.to_s.downcase.to_sym)
        params.merge!(headers: headers)
        Typhoeus.send(method.to_s.downcase.to_sym, "#{ApiClient.base_url}/api/#{uri}", params)
      rescue Exception => ex
        attempts = attempts + 1
        retry if attempts < API_MAX_ATTEMPTS
      end
    end

    private

    def api_authorization_header
      hashed_token = "#{@token}:#{@secret}"
      "Basic #{Base64.urlsafe_encode64(hashed_token)}"
    end

    def api_request_headers
      {
          'User-Agent'          => API_USER_AGENT,
          'X-API-Authorization' => api_authorization_header
      }
    end
  end
end
