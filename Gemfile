# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'appveyor-worker', '~> 0.2'
gem 'bump', require: false
gem 'pry'
gem 'pry-byebug' if RUBY_ENGINE == 'ruby'
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.7'
gem 'rubocop-rspec', '~> 1.29.0'
gem 'simplecov', '~> 0.10'
gem 'test-queue'
gem 'yard', '~> 0.9'

group :test do
  gem 'safe_yaml', require: false
  gem 'webmock', require: false
end

local_gemfile = 'Gemfile.local'
eval_gemfile local_gemfile if File.exist?(local_gemfile)
