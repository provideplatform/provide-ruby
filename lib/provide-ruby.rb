require 'active_support/core_ext/hash/indifferent_access'
require 'base64'
require 'json'
require 'provide-ruby/version'
require 'provide-ruby/amqp'
require 'provide-ruby/api_client'
require 'provide-ruby/models/model'
require 'provide-ruby/models/customer'
require 'provide-ruby/models/market'
require 'provide-ruby/models/origin'
require 'provide-ruby/models/product'
require 'provide-ruby/models/provider'
require 'provide-ruby/models/provider_origin_assignment'
require 'provide-ruby/models/route'
require 'provide-ruby/models/work_order'

module Provide
  API_TOKEN = ENV['API_TOKEN'] || (raise ArgumentError.new('API_TOKEN environment variable must be set'))
  API_TOKEN_SECRET = ENV['API_TOKEN_SECRET'] || (raise ArgumentError.new('API_TOKEN_SECRET environment variable must be set'))
  API_COMPANY_ID = ENV['API_COMPANY_ID'] || (raise ArgumentError.new('API_COMPANY_ID environment variable must be set'))
  API_MARKET_ID = ENV['API_MARKET_ID'] || (raise ArgumentError.new('API_MARKET_ID environment variable must be set'))

  class << self
    def run
      routes = {}

      subscribe_queue = ENV['AMQP_SUBSCRIBE_QUEUE'] || (raise ArgumentError.new('AMQP_SUBSCRIBE_QUEUE environment variable must be set'))
      publish_queue = ENV['AMQP_PUBLISH_QUEUE'] || (raise ArgumentError.new('AMQP_PUBLISH_QUEUE environment variable must be set'))

      amqp = Provide::AMQP.new
      amqp.process_queue(subscribe_queue) do |raw_payload|
        payload = JSON.parse(raw_payload).with_indifferent_access
        payload.keys.each do |raw_key|
          key = raw_key.downcase.strip.gsub(/\s+/, '_')
          value = payload[raw_key]
          payload[key] = value
        end
        payload = payload.with_indifferent_access

        product = save_product(payload)
        customer = save_customer(payload)
        origin = save_origin(payload)
        provider = save_provider(payload)
        provider_origin_assignment = save_provider_origin_assignment(provider, origin, payload)

        routes[payload[:delivery_run_id]] ||= { 
          landing_sks: [],
          customers: {},
          route_id: payload[:route_id],
          provider_origin_assignment: provider_origin_assignment,
          products: [],
          work_order_ids: []
        }

        routes[payload[:delivery_run_id]][:landing_sks] << payload[:landing_sks]
        routes[payload[:delivery_run_id]][:products] << product
        routes[payload[:delivery_run_id]][:customers][customer[:id]] ||= { work_order: nil, products: []}
        routes[payload[:delivery_run_id]][:customers][customer[:id]][:products] << product
      end

      routes.each do |delivery_run_id, route_obj|
        landing_sks = route_obj[:landing_sks]
        ## TODO- calculate missing # of products using landing_sks.count - products.count

        provider_origin_assignment = route_obj[:provider_origin_assignment]
        provider = provider_origin_assignment[:provider]

        route_obj[:customers].each do |customer_id, customer|
          work_order = Provide::WorkOrder.new
          work_order[:id] = customer[:work_order][:id] if customer[:work_order] && customer[:work_order][:id]
          work_order[:company_id] = API_COMPANY_ID
          work_order[:customer_id] = customer_id
          work_order[:preferred_scheduled_start_date] = provider_origin_assignment[:start_date]
          work_order[:gtins_ordered] = customer[:products].map { |product| product[:gtin] }
          work_order[:work_order_providers] = [ { provider_id: provider[:id] } ]

          work_order.save

          route_obj[:work_order_ids] << work_order[:id] unless route_obj[:work_order_ids].include?(work_order[:id])
        end

        route = Provide::Route.new
        route[:name] = "#{route_obj[:start_time]} - #{route_obj[:end_time]}"
        route[:identifier] = delivery_run_id
        route[:date] = provider_origin_assignment[:start_date]
        route[:provider_origin_assignment_id] = provider_origin_assignment[:id]
        route[:work_order_ids] = route_obj[:work_order_ids]
        route.save

        route_obj[:work_order_ids].each do |work_order_id|
          message_payload = { 
            landing_sks: landing_sks,
            work_order_id: work_order_id,
            provider_id: provider[:id],
            route_id: route_obj[:id]
          }
          amqp.queue(publish_queue).publish(message_payload.to_json)
        end
      end

      routes
    rescue StandardError => e
      puts "caught standard error #{e}"
    end
    
    def save_product(payload)
      product = Provide::Product.new
      product[:data] = {
        name: payload[:product_name]
      }
      product[:gtin] = payload[:variant_number]
      product.save
      product
    end
    
    def save_customer(payload)
      customer = Provide::Customer.new
      contact = {
        name: "#{payload[:first_name]} #{payload[:last_name]}",
        address1: payload[:address],
        city: payload[:city],
        state: payload[:state],
        zip: payload[:zip],
        time_zone_id: 'Eastern Time (US & Canada)', # FIXME
        email: "kyle+#{payload[:first_name]}@unmarkedconsulting.com", # FIXME-- be very sure we are ready when uncommenting here... payload['email']
        phone: '8599673476', # FIXME-- be very sure we are ready when uncommenting here... payload['phone1']
        mobile: '8599673476', # FIXME-- be very sure we are ready when uncommenting here... payload['phone2']
      }
      customer[:customer_number] = payload[:customer_number]
      customer[:contact] = contact
      customer[:company_id] = API_COMPANY_ID
      customer.save
      customer
    end
    
    def save_origin(payload)
      origin = Provide::Origin.new
      origin[:market_id] = API_MARKET_ID
      contact = {
        name: "Warehouse ##{payload[:warehouse]}",
        address1: nil,
        city: nil,
        state: nil,
        zip: nil,
        time_zone_id: 'Eastern Time (US & Canada)', # FIXME
        email: nil,
        phone: nil,
        mobile: nil,
      }
      origin[:warehouse_number] = payload[:warehouse]
      origin[:contact] = contact
      origin.save
      origin
    end
    
    def save_provider(payload)
      provider = Provide::Provider.new
      contact = {
        name: payload[:contractor_name],
        address1: nil,
        city: nil,
        state: nil,
        zip: nil,
        time_zone_id: 'Eastern Time (US & Canada)', # FIXME
        email: nil,
        phone: nil,
        mobile: nil,
      }
      provider[:contact] = contact
      provider[:company_id] = API_COMPANY_ID
      provider.save
      provider
    end
    
    def save_provider_origin_assignment(provider, origin, payload)
      provider_origin_assignment = Provide::ProviderOriginAssignment.new
      provider_origin_assignment[:market_id] = origin[:market_id]
      provider_origin_assignment[:origin_id] = origin[:id]
      provider_origin_assignment[:provider_id] = provider[:id]
      
      date = payload[:ship_date].split(/\//)
      date = "#{date[2]}-#{date[0]}-#{date[1]}"
      
      provider_origin_assignment[:start_date] = date
      provider_origin_assignment[:end_date] = date
      provider_origin_assignment.save
      provider_origin_assignment
    end
  end
end
