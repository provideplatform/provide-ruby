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

require 'typhoeus'

API_SCHEME = ENV['API_SCHEME'] || 'https'
API_HOST = ENV['API_HOST'] || 'api.provide.services'
API_USER_AGENT = ENV['API_USER_AGENT'] || 'provide-ruby client library'
API_MAX_ATTEMPTS = (ENV['API_MAX_ATTEMPTS'] || 5).to_i
API_TIMEOUT = (ENV['API_TIMEOUT'] || 120).to_i
API_PROMISCUOUS_MODE = ENV['API_PROMISCUOUS_MODE'].to_s.match(/^true$/i)

module Provide
  class ApiClient

    attr_reader :base_url, :token

    def initialize(scheme = API_SCHEME, host = API_HOST, path = 'api/', token = nil)
      @base_url = "#{scheme}://#{host}/#{path}"
      @token = token
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
        params.merge!(headers: headers, timeout: API_TIMEOUT)
        params.merge!(ssl_verifypeer: false, ssl_verifyhost: 0) if API_PROMISCUOUS_MODE
        Typhoeus.send(method.to_s.downcase.to_sym, "#{base_url}#{uri}", params)
      rescue
        attempts = attempts + 1
        retry if attempts < API_MAX_ATTEMPTS
      end
    end

    private

    def default_headers
      headers = {}
      headers['User-Agent'] = API_USER_AGENT
      headers['Authorization'] = "bearer #{token}" if token
      headers
    end
  end
end
