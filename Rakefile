require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :console do
  exec 'irb --readline -r provide-ruby -I ./lib'
end
