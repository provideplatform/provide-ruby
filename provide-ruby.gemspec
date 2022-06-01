# coding: utf-8

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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'provide-ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'provide-ruby'
  spec.version       = Provide::VERSION
  spec.authors       = ['Kyle Thomas']
  spec.email         = ['kyle@provide.services']

  spec.summary       = 'Provide Ruby API client library'
  spec.homepage      = 'https://github.com/provideplatform/provide-ruby.git'
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
