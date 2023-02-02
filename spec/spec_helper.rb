# frozen_string_literal: true

# Disable colors in specs
require 'rainbow'
Rainbow.enabled = false

require 'rubocop'
require 'rubocop/cop/internal_affairs'
require 'rubocop/server'

require 'webmock/rspec'

require_relative 'core_ext/string'

begin
  require 'pry'
rescue LoadError
  # Pry is not activated.
end

# Require supporting files exposed for testing.
require 'rubocop/rspec/support'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # This setting works together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  unless defined?(TestQueue)
    # See. https://github.com/tmm1/test-queue/issues/60#issuecomment-281948929
    config.filter_run_when_matching :focus
  end

  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.include RuboCop::RSpec::ExpectOffense

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec
  config.mock_with :rspec

  config.before(:suite) do
    RuboCop::Cop::Registry.global.freeze
    # This ensures that there are no side effects from running a particular spec.
    # Use `:restore_registry` / `RuboCop::Cop::Registry.with_temporary_global` if
    # need to modify registry (e.g. with `stub_cop_class`).
  end

  config.after(:suite) { RuboCop::Cop::Registry.reset! }

  if %w[ruby-head-ascii_spec ruby-head-spec].include? ENV.fetch('CIRCLE_JOB', nil)
    config.filter_run_excluding broken_on: :ruby_head
  end

  config.filter_run_excluding broken_on: :jruby if ENV.fetch('GITHUB_JOB', nil) == 'jruby'
end

module ::RSpec
  module Core
    class ExampleGroup
      # Override `failure_count` from test-queue to prevent RSpec deprecation notice
      # Treating `metadata[:execution_result]` as a hash is deprecated.
      def self.failure_count
        examples.map { |e| e.execution_result.status == 'failed' }.length
      end
    end
  end
end
