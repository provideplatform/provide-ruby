require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :console do
  exec 'irb -r provide-ruby -I ./lib'
end

task :mfrm do
  ENV['API_TOKEN'] = '6091f60f-b583-456a-8992-4389a0e4ff83'
  ENV['API_TOKEN_SECRET'] = 'bcca731223217f3dd7fb2d66882be7ed'
  ENV['API_COMPANY_ID'] = '4'
  ENV['API_MARKET_ID'] = '3'
  ENV['API_DISPATCHER_ID'] = '5'
  ENV['AMQP_SUBSCRIBE_QUEUE'] = 'MFMRM'
  ENV['AMQP_PUBLISH_QUEUE'] = 'provide'
  ENV['AMQP_FAILED_QUEUE'] = 'provide_failed'
  ENV['AMQP_HOST'] = 'localhost'
  ENV['AMQP_USERNAME'] = 'provide'
  ENV['AMQP_PASSWORD'] = 'provide'

  require "bundler/setup"
  require "provide-ruby"

  puts 'Running provide mfrm etl...'
  Provide.run
end
