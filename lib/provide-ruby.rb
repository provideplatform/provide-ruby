require 'active_support/core_ext/date_time/calculations'
require 'active_support/core_ext/hash/indifferent_access'
require 'base64'
require 'json'
require 'provide-ruby/version'
require 'provide-ruby/amqp'
require 'provide-ruby/api_client'
require 'provide-ruby/models/model'
require 'provide-ruby/models/customer'
require 'provide-ruby/models/dispatcher'
require 'provide-ruby/models/dispatcher_origin_assignment'
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
  API_DISPATCHER_ID = ENV['API_MARKET_ID'] || (raise ArgumentError.new('API_MARKET_ID environment variable must be set'))
  API_DATE_OVERRIDE = ENV['API_DATE_OVERRIDE'] || nil

  class << self
    def run
      routes = {}

      subscribe_queue = ENV['AMQP_SUBSCRIBE_QUEUE'] || (raise ArgumentError.new('AMQP_SUBSCRIBE_QUEUE environment variable must be set'))
      publish_queue = ENV['AMQP_PUBLISH_QUEUE'] || (raise ArgumentError.new('AMQP_PUBLISH_QUEUE environment variable must be set'))
      failed_queue = ENV['AMQP_FAILED_QUEUE'] || (raise ArgumentError.new('AMQP_FAILED_QUEUE environment variable must be set'))

      amqp = Provide::AMQP.new
      amqp.process_queue(subscribe_queue) do |raw_payload|
        begin
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
          dispatcher = save_dispatcher(payload)
          dispatcher_origin_assignment = save_dispatcher_origin_assignment(dispatcher, origin, payload)
          provider = save_provider(payload)
          provider_origin_assignment = save_provider_origin_assignment(provider, origin, payload)
          
          zone_code = payload[:zone_code]

          routes[zone_code] ||= { 
            landing_sks: [],
            customers: {},
            route_id: payload[:route_id],
            dispatcher_origin_assignment: dispatcher_origin_assignment,
            provider_origin_assignment: provider_origin_assignment,
            products: [],
            work_orders: [],
            work_order_ids: [],
            zone_code: payload[:zone_code],
            start_time: payload[:start_time],
            end_time: payload[:end_time]
          }

          routes[zone_code][:products] << product
          routes[zone_code][:landing_sks] << payload[:landing_sk]
          routes[zone_code][:customers][customer[:id]] ||= { products: [], work_order: nil }
          routes[zone_code][:customers][customer[:id]][:products] << product
        rescue StandardError => e
          failed_payload = {
            error: "#{e}",
            raw: payload,
            product: product,
            customer: customer,
            origin: origin,
            dispatcher: dispatcher,
            dispatcher_origin_assignment: dispatcher_origin_assignment,
            provider: provider,
            provider_origin_assignment: provider_origin_assignment
          }
          amqp.queue(failed_queue).publish(failed_payload.to_json)
        end
      end
      
      routes.each do |zone_code, route_obj|
        landing_sks = route_obj[:landing_sks]
        ## TODO- calculate missing # of products using landing_sks.count - products.count

        customers = route_obj[:customers].values
        provider_origin_assignment = route_obj[:provider_origin_assignment]
        provider = provider_origin_assignment[:provider] 

        route_obj[:customers].each do |customer_id, customer|
          work_order = Provide::WorkOrder.new # FIXME -- make sure work order operation is idempotent
          work_order[:id] = customer[:work_order][:id] if customer[:work_order] && customer[:work_order][:id]
          work_order[:company_id] = API_COMPANY_ID
          work_order[:customer_id] = customer_id
          work_order[:preferred_scheduled_start_date] = provider_origin_assignment[:start_date]
          work_order[:gtins_ordered] = customer[:products].map { |product| product[:gtin] }
          work_order[:work_order_providers] = [ { provider_id: provider[:id] } ] if provider

          work_order.save

          route_obj[:work_orders] << work_order unless route_obj[:work_order_ids].include?(work_order[:id])
          route_obj[:work_order_ids] << work_order[:id] unless route_obj[:work_order_ids].include?(work_order[:id])
        end
        
        route = Provide::Route.new
        route[:name] = route_obj[:zone_code] #"#{route_obj[:start_time]} - #{route_obj[:end_time]}"
        route[:identifier] = zone_code
        route[:date] = provider_origin_assignment[:start_date] if provider_origin_assignment
        # route[:scheduled_start_at] = provider_origin_assignment[:scheduled_start_at] if provider_origin_assignment
        route[:dispatcher_origin_assignment_id] = dispatcher_origin_assignment[:id] if dispatcher_origin_assignment #FIXME make sure dispatcher origin assignment is set
        route[:provider_origin_assignment_id] = provider_origin_assignment[:id] if provider_origin_assignment
        route[:work_order_ids] = route_obj[:work_order_ids]
        route.save
        
        route_obj[:work_orders].each do |work_order|
          message_payload = {
            landing_sks: landing_sks,
            work_order_id: work_order[:id],
            provider_id: provider ? provider[:id] : nil,
            route_id: route[:id]
          }
          amqp.queue(publish_queue).publish(message_payload.to_json)
        end
      end

      routes
    rescue StandardError => e
      puts "caught standard error #{e}"
      retry
    end
    
    def save_product(payload)
      product = Provide::Product.new
      product[:data] = {
        name: payload[:product_name],
        size: payload[:size]
      }
      product[:gtin] = payload[:variant_number]
      product.save
      product
    end
    
    def save_customer(payload)
      customer = Provide::Customer.new
      address_length = (payload[:address].rindex(payload[:city]) || payload[:address].length) - 1
      address = payload[:address][0..address_length].strip
      contact = {
        name: payload[:customer_name], #"#{payload[:first_name]} #{payload[:last_name]}",
        address1: address,
        city: payload[:city],
        state: payload[:state],
        zip: payload[:zipcode],
        time_zone_id: 'Eastern Time (US & Canada)', # FIXME
        email: "kyle+#{payload[:customer_name].gsub(/\s+/, '').strip.downcase}@unmarkedconsulting.com", # FIXME-- be very sure we are ready when uncommenting here... payload['email']
        phone: '8599673476', # FIXME-- be very sure we are ready when uncommenting here... payload['phone_1']
        mobile: '8599673476', # FIXME-- be very sure we are ready when uncommenting here... payload['phone_2']
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
        address1: '311 Summer Dr NE', #nil,
        city: 'Atlanta', #nil,
        state: 'GA', #nil,
        zip: '30328', #nil,
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

    def save_dispatcher(payload)
      return Provide::Dispatcher.find(API_DISPATCHER_ID) if API_DISPATCHER_ID
      dispatcher = Provide::Dispatcher.new
      contact = {
          name: nil,
          address1: nil,
          city: nil,
          state: nil,
          zip: nil,
          time_zone_id: 'Eastern Time (US & Canada)', # FIXME
          email: nil,
          phone: nil,
          mobile: nil,
      }
      dispatcher[:contact] = contact
      dispatcher[:company_id] = API_COMPANY_ID
      dispatcher.save
      dispatcher
    end

    def save_dispatcher_origin_assignment(dispatcher, origin, payload)
      dispatcher_origin_assignment = Provide::DispatcherOriginAssignment.new
      dispatcher_origin_assignment[:market_id] = origin[:market_id]
      dispatcher_origin_assignment[:origin_id] = origin[:id]
      dispatcher_origin_assignment[:dispatcher_id] = dispatcher ? dispatcher[:id] : API_DISPATCHER_ID

      date = payload[:ship_date].split(/\//)
      date = API_DATE_OVERRIDE || "#{date[2]}-#{date[0]}-#{date[1]}"

      dispatcher_origin_assignment[:start_date] = date
      dispatcher_origin_assignment[:end_date] = date
      dispatcher_origin_assignment.save
      dispatcher_origin_assignment
    end
    
    def save_provider(payload)
      return Provide::Provider.find(API_PROVIDER_ID) if API_PROVIDER_ID
      provider = Provide::Provider.new
      contact = {
        name: payload[:contractor_name],
        address1: nil,
        city: nil,
        state: nil,
        zip: nil,
        time_zone_id: 'Eastern Time (US & Canada)', # FIXME
        email: "kyle+provider#{payload[:contractor_name].downcase.gsub(/\s+/, '').strip}@unmarkedconsulting.com",
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
      provider_origin_assignment[:provider_id] = provider ? provider[:id] : API_PROVIDER_ID
      
      date = payload[:ship_date].split(/\//)
      date = API_DATE_OVERRIDE || "#{date[2]}-#{date[0]}-#{date[1]}"
      
      provider_origin_assignment[:start_date] = date
      provider_origin_assignment[:end_date] = date
      provider_origin_assignment[:scheduled_start_at] = (Date.parse(date).to_datetime.midnight. + payload[:start_time]).to_datetime
      #provider_origin_assignment[:scheduled_end_at] = date
      provider_origin_assignment.save
      provider_origin_assignment
    end
  end
end
