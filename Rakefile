require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :console do
  exec 'irb -r provide-ruby -I ./lib'
end

task :mfrm do
  ENV['API_SCHEME'] = 'http'
  ENV['API_HOST'] = '52.5.92.0' #'api-production-us-east-595727586.us-east-1.elb.amazonaws.com'
  ENV['API_TOKEN'] = '2a991777-12ba-4a89-b5db-572171e15af0' #'6091f60f-b583-456a-8992-4389a0e4ff83'
  ENV['API_TOKEN_SECRET'] = '276130a3b7c4ad65a0f7f5d2a5aaed02' #'bcca731223217f3dd7fb2d66882be7ed'
  ENV['API_COMPANY_ID'] = '5' #'4'
  ENV['API_MARKET_ID'] = '4'
  ENV['API_DISPATCHER_ID'] = '14'
  ENV['AMQP_SUBSCRIBE_QUEUE'] = 'MFMRM'
  ENV['AMQP_PUBLISH_QUEUE'] = 'provide'
  ENV['AMQP_FAILED_QUEUE'] = 'provide_failed'
  ENV['AMQP_HOST'] = 'mfrm1.provide.services'
  ENV['AMQP_USERNAME'] = 'provide'
  ENV['AMQP_PASSWORD'] = 'provide'

  require "bundler/setup"
  require "provide-ruby"

  puts 'Running provide mfrm etl...'
  Provide.run
end
