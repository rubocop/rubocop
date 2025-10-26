# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'asciidoctor'
gem 'bump', require: false
gem 'fiddle', platform: :windows if RUBY_VERSION >= '3.4'
gem 'irb'
gem 'memory_profiler', '!= 1.0.2', platform: :mri
gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.7'
gem 'rubocop-performance', '~> 1.26.0'
gem 'rubocop-rake', '~> 0.7.0'
gem 'rubocop-rspec', '~> 3.7.0'
# Ruby LSP supports Ruby 3.0+.
gem 'ruby-lsp', '~> 0.24', platform: :mri if RUBY_VERSION >= '3.0'
gem 'simplecov', '~> 0.20'
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
