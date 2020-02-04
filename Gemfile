# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'bump', require: false
gem 'pry'
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.7'
gem 'rubocop-performance', '~> 1.5.0'
gem 'rubocop-rspec', '~> 1.33.0'
# Workaround for cc-test-reporter with SimpleCov 0.18.
# Stop upgrading SimpleCov until the following issue will be resolved.
# https://github.com/codeclimate/test-reporter/issues/418
gem 'simplecov', '~> 0.10', '< 0.18'
gem 'test-queue'
gem 'yard', '~> 0.9'

group :test do
  # Workaround for crack 0.4.3 or lower.
  # Depends on `rexml` until the release that includes
  # the following changes:
  # https://github.com/jnunemaker/crack/pull/62
  gem 'rexml'
  gem 'safe_yaml', require: false
  gem 'webmock', require: false
end

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
