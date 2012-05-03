# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rubocop"
  gem.homepage = "http://github.com/bbatsov/rubocop"
  gem.license = "MIT"
  gem.summary = %Q{Automatic Ruby code style checking tool.}
  gem.description = %Q{Automatic Ruby code style checking tool. Aims to enforce the community-driven Ruby Style Guide.}
  gem.email = "bozhidar@batsov.com"
  gem.authors = ["Bozhidar Batsov"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
