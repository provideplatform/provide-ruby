# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'provide-ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'provide-ruby'
  spec.version       = Provide::VERSION
  spec.authors       = ['Kyle Thomas']
  spec.email         = ['k.thomas@unmarkedconsulting.com']

  spec.summary       = 'Provide ruby client library'
  spec.homepage      = 'https://github.com/provideapp/provide-ruby.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'typhoeus', '~> 1.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.3'
end
