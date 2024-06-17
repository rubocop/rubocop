# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'asciidoctor'
gem 'bump', require: false
gem 'bundler', '>= 1.15.0', '< 3.0'
# FIXME: This is a workaround to prevent the following warning in YARD:
# https://github.com/lsegal/yard/pull/1546
# Please remove this dependency when the issue is resolved.
gem 'logger'
gem 'memory_profiler', platform: :mri
# FIXME: This is a workaround to prevent the following warning in YARD:
# https://github.com/lsegal/yard/pull/1545
# Please remove this dependency when the issue is resolved.
gem 'ostruct'
gem 'prism', '>= 0.30.0'
gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.7'
gem 'rubocop-performance', '~> 1.21.0'
gem 'rubocop-rake', '~> 0.6.0'
gem 'rubocop-rspec', '~> 3.0.0'
# Workaround for cc-test-reporter with SimpleCov 0.18.
# Stop upgrading SimpleCov until the following issue will be resolved.
# https://github.com/codeclimate/test-reporter/issues/418
gem 'simplecov', '~> 0.10', '< 0.18'
gem 'stackprof', platform: :mri
gem 'test-queue'
gem 'yard', '~> 0.9'

group :test do
  gem 'webmock', require: false
end

local_ast = File.expand_path('../rubocop-ast', __dir__)
gem 'rubocop-ast', path: local_ast if Dir.exist? local_ast

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
