# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'pry'
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.5.0'
gem 'simplecov', '~> 0.10'
gem 'yard', '~> 0.8'

group :test do
  gem 'codeclimate-test-reporter', '~> 1.0', require: false
  gem 'safe_yaml', require: false
  gem 'webmock', require: false
end

local_gemfile = 'Gemfile.local'
eval_gemfile local_gemfile if File.exist?(local_gemfile)
