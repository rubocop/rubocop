# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'bundler/gem_tasks'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

desc 'Run RuboCop over itself'
Rubocop::RakeTask.new(:internal_investigation)

task default: [:spec, :internal_investigation]

require 'yard'
YARD::Rake::YardocTask.new

Rubocop::RakeTask.new
