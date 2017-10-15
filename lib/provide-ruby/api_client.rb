require 'typhoeus'

API_SCHEME = ENV['API_SCHEME'] || 'https'
API_HOST = ENV['API_HOST'] || 'provide.services'
API_USER_AGENT = ENV['API_USER_AGENT'] || 'provide-ruby client library'
API_MAX_ATTEMPTS = (ENV['API_MAX_ATTEMPTS'] || 5).to_i

module Provide
  class ApiClient

    attr_reader :base_url, :token, :secret

    def initialize(scheme = API_SCHEME, host = API_HOST, path = 'api/', token = nil, secret = nil)
      @base_url = "#{scheme}://#{host}/#{path}"
      @token = token
      @secret = secret
    end

    def get(uri, params = nil)
      send_request(:get, uri, params || {})
    end

    def post(uri, params = nil)
      send_request(:post, uri, params || {})
    end

    def put(uri, params = nil)
      send_request(:put, uri, params || {})
    end

    def delete(uri, params = nil)
      send_request(:delete, uri, params || {})
    end

    def send_request(method, uri, params = nil, headers = nil)
      attempts = 0

      begin
        params = [:post, :put, :patch].include?(method.to_s.downcase.to_sym) ? { body: JSON.dump(params) } : { params: params }
        headers = default_headers.merge(headers || {})
        headers['Content-Type'] = 'application/json' if [:post, :put, :patch].include?(method.to_s.downcase.to_sym)
        params.merge!(headers: headers)
        Typhoeus.send(method.to_s.downcase.to_sym, "#{base_url}#{uri}", params)
      rescue
        attempts = attempts + 1
        retry if attempts < API_MAX_ATTEMPTS
      end
    end

    private

    def api_authorization_header
      return nil unless token && secret
      creds = "#{token}:#{secret}"
      "Basic #{Base64.urlsafe_encode64(creds)}"
    end

    def default_headers
      headers = {}
      headers['User-Agent'] = API_USER_AGENT
      headers['X-API-Authorization'] = api_authorization_header if api_authorization_header
      headers
    end
  end
end
