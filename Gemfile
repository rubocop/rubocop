# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'bump', require: false
gem 'pry'
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.7'
gem 'rubocop-performance', '~> 1.5.0'
gem 'rubocop-rspec', '~> 1.33.0'
gem 'simplecov', '~> 0.10'
gem 'test-queue'
# Workaround for YARD 0.9.20 or lower.
# It specifies `github` until the release that includes the following changes:
# https://github.com/lsegal/yard/pull/1290
gem 'yard', github: 'lsegal/yard', ref: '10a2e5b'

group :test do
  gem 'safe_yaml', require: false
  gem 'webmock', require: false
end

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
