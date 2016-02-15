require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :console do
  exec 'irb -r provide-ruby -I ./lib'
end

task :cottage do
  ENV['API_SCHEME'] = 'http'
  ENV['API_HOST'] = '52.5.92.0' #'api-production-us-east-595727586.us-east-1.elb.amazonaws.com'
  ENV['API_TOKEN'] = 'dc754995-75cb-4545-950b-517d3d37d8dc' #'6091f60f-b583-456a-8992-4389a0e4ff83'
  ENV['API_TOKEN_SECRET'] = '07776e04567a6c61f25259def7e18c6f' #'bcca731223217f3dd7fb2d66882be7ed'
  ENV['API_COMPANY_ID'] = '1'
  ENV['API_CUSTOMER_ID'] = '3483'
  ENV['API_MARKET_ID'] = '7'
  ENV['API_ORIGIN_ID'] = '486'
  ENV['API_DISPATCHER_ID'] = '1'
  ENV['API_PROVIDER_ID'] = '2'
  ENV['API_DATE_OVERRIDE'] = nil
  ENV['API_FORCE_SCHEDULE'] = 'true'
  ENV['API_ORDERED_PRODUCTS_COUNT'] = '5'
  ENV['API_DUPLICATE_ORDERED_PRODUCT'] = 'true'

  require 'bundler/setup'
  require 'faker'
  require 'provide-ruby'

  puts 'Running cottage circle route seed...'
  Provide.seed_test
end

task :mwcleaners_customer do
  require 'faker'
  
  ENV['API_SCHEME'] = 'http'
  ENV['API_HOST'] = '52.5.92.0' #'api-production-us-east-595727586.us-east-1.elb.amazonaws.com'
  ENV['API_TOKEN'] = '22465739-54da-460d-bf4b-4c484ceba038' #'0366b928-4119-48b6-a352-bded1dd01a73' #'6091f60f-b583-456a-8992-4389a0e4ff83'
  ENV['API_TOKEN_SECRET'] = 'a0574a586f55971e875b79bc73a45fbf' #'13c12aacc6851606fcd2f5bb60c87166' #'bcca731223217f3dd7fb2d66882be7ed'
  ENV['API_COMPANY_ID'] = '13'

  require 'bundler/setup'
  require 'provide-ruby'
  
  address_zip_pairs = [
    ['2526 potomac unit b', '77057'],
    ['5822 Burlinghall', '77035'],
    ['3747 University Blvd', '77005'],
    ['4806 Palm St', '77401'],
    ['6432 Ella Lee Ln #4', '77057'],
    ['7575 BISSONET #278', '77074'],
    ['3902 Drake', '77005'],
    ['1009 W 24th St', '77008'],
    ['4410 Westheimer Rd apt 3439', '77027']
  ]
  
  address_zip_pairs.size.times do
    address_zip_pair = address_zip_pairs.shift
    
    payload = {
      customer_name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
      address: address_zip_pair.first,
      city: 'Houston',
      state: 'TX',
      zipcode: address_zip_pair.last,
      time_zone_id: 'Central Time (US & Canada)'
    }

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
    customer[:company_id] = ENV['API_COMPANY_ID']
    customer.save
  
    puts "customer created: #{customer}"
  end
end

task :mwcleaners do
  ENV['API_SCHEME'] = 'http'
  ENV['API_HOST'] = '52.5.92.0' #'api-production-us-east-595727586.us-east-1.elb.amazonaws.com'
  ENV['API_TOKEN'] = '22465739-54da-460d-bf4b-4c484ceba038' #'0366b928-4119-48b6-a352-bded1dd01a73' #'6091f60f-b583-456a-8992-4389a0e4ff83'
  ENV['API_TOKEN_SECRET'] = 'a0574a586f55971e875b79bc73a45fbf' #'13c12aacc6851606fcd2f5bb60c87166' #'bcca731223217f3dd7fb2d66882be7ed'
  ENV['API_COMPANY_ID'] = '13'
  ENV['API_MARKET_ID'] = nil
  ENV['API_DISPATCHER_ID'] = nil
  ENV['API_PROVIDER_ID'] = nil
  ENV['API_DATE_OVERRIDE'] = nil
  ENV['API_FORCE_SCHEDULE'] = 'true'

  require 'bundler/setup'
  require 'provide-ruby'

  #Provide.run
end

task :mfrm do
  ENV['API_SCHEME'] = 'http'
  ENV['API_HOST'] = '52.5.92.0' #'api-production-us-east-595727586.us-east-1.elb.amazonaws.com'
  ENV['API_TOKEN'] = '0366b928-4119-48b6-a352-bded1dd01a73' #'6091f60f-b583-456a-8992-4389a0e4ff83'
  ENV['API_TOKEN_SECRET'] = '13c12aacc6851606fcd2f5bb60c87166' #'bcca731223217f3dd7fb2d66882be7ed'
  ENV['API_COMPANY_ID'] = '7'
  ENV['API_MARKET_ID'] = '13'
  ENV['API_DISPATCHER_ID'] = '20'
  ENV['API_PROVIDER_ID'] = '302'
  ENV['API_DATE_OVERRIDE'] = nil
  ENV['API_FORCE_SCHEDULE'] = 'true'
  ENV['AMQP_SUBSCRIBE_QUEUE'] = 'mfrm_router'
  ENV['AMQP_PUBLISH_QUEUE'] = 'provide'
  ENV['AMQP_FAILED_QUEUE'] = 'provide_failed'
  ENV['AMQP_HOST'] = 'mfrm1.provide.services'
  ENV['AMQP_USERNAME'] = 'provide'
  ENV['AMQP_PASSWORD'] = 'provide'

  require 'bundler/setup'
  require 'provide-ruby'

  puts 'Running provide mfrm etl...'
  Provide.run
end

require 'resque/tasks'

task 'resque:setup' do
  lib_path = "#{File.dirname(__FILE__)}/lib"
  require "#{lib_path}/provide-ruby.rb"

  redis_url = ENV['REDIS_URL']
  if redis_url
    uri = URI.parse(redis_url)
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end
end

task :houzz do
  ENV['API_SCHEME'] = 'https'
  ENV['API_HOST'] = 'provide.services'
  ENV['API_TOKEN'] = 'e3ab4133-e2fc-422b-a7d2-bfd105c5ae52'
  ENV['API_TOKEN_SECRET'] = '886ef00fabbd9b5e07cb1694e0f71fa5'
  require 'bundler/setup'
  require 'provide-ruby'
  
  binding.pry
end

task :emser do
  ENV['API_SCHEME'] = 'https'
  ENV['API_HOST'] = 'provide.services'
  ENV['API_TOKEN'] = 'b6f1bb9a-04af-43d1-af98-7e47c6227192'
  ENV['API_TOKEN_SECRET'] = 'af258f243f6b59f3df48bf4e5ea82f02'
  ENV['API_COMPANY_ID'] = '25'
  require 'bundler/setup'
  require 'provide-ruby'
  
  binding.pry
end
