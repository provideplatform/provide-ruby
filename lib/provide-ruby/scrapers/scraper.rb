require 'nokogiri'

module Provide
  class Scraper
    
    class << self
      def valid_user_agents
        [
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36'
        ]
      end
    end

    attr_reader :base_url

    def initialize(base_url)
      @base_url = base_url
    end

    def fetch(uri, query_params = {})
      response = Typhoeus::Request.get("#{base_url}#{uri}?#{URI.encode_www_form(query_params)}",
                                       headers: { 'User-Agent' => Scraper.valid_user_agents.sample })
      Nokogiri::HTML(response.body) if response && (response.code == 200 || response.code == 304)
    end
  end
end
