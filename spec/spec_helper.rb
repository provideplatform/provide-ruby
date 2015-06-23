$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'bundler'
Bundler.setup
require 'typhoeus'
require 'rspec'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }
