require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'nokogiri'

Capybara.default_driver = :poltergeist
Capybara.run_server = false

module Provide
  class Scraper
    include Capybara::DSL
    
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
      url = "#{base_url}#{uri}"
      url += "?#{URI.encode_www_form(query_params)}" if query_params && query_params.size > 0
      response = Typhoeus::Request.get(url,
                                       headers: { 'User-Agent' => Scraper.valid_user_agents.sample })
      Nokogiri::HTML(response.body) if response && (response.code == 200 || response.code == 304)
    end
    
    def visit(uri, query_params = {})
      url = "#{base_url}#{uri}"
      url += "?#{URI.encode_www_form(query_params)}" if query_params && query_params.size > 0
      super(url)
      Nokogiri::HTML(page.html) if page && page.html
    end
  end
end
