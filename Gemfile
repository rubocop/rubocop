# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'asciidoctor'
gem 'bump', require: false
gem 'bundler', '>= 1.15.0', '< 3.0'
gem 'memory_profiler', platform: :mri
gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.7'
gem 'rubocop-performance', '~> 1.19.0'
gem 'rubocop-rake', '~> 0.6.0'
gem 'rubocop-rspec', '~> 2.24.0'
# Workaround for cc-test-reporter with SimpleCov 0.18.
# Stop upgrading SimpleCov until the following issue will be resolved.
# https://github.com/codeclimate/test-reporter/issues/418
gem 'simplecov', '~> 0.10', '< 0.18'
gem 'stackprof', platform: :mri
gem 'test-queue'
gem 'yard', '~> 0.9'

group :test do
  # FIXME: This `base64` dependency can be removed when https://github.com/bblimke/webmock/pull/1041
  # is merged and released. It's a workaround until then.
  gem 'base64'
  # FIXME: This `bigdecimal` dependency can be removed when https://github.com/jnunemaker/crack/pull/75
  # is merged and released. It's a workaround until then.
  gem 'bigdecimal', platform: :mri
  gem 'webmock', require: false
end

local_ast = File.expand_path('../rubocop-ast', __dir__)
gem 'rubocop-ast', path: local_ast if Dir.exist? local_ast

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
