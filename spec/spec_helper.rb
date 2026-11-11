# frozen_string_literal: true

# Disable colors in specs
require 'rainbow'
Rainbow.enabled = false

require_relative 'support/strict_warnings'
StrictWarnings.enable!

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

# NOTE: To avoid executing processes needed only for extension plugins in `rubocop/rspec/support`,
# an environment variable is used to indicate that it is running in the RuboCop core development.
ENV['RUBOCOP_CORE_DEVELOPMENT'] = 'true'

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

  # A single filter, because RSpec keeps only the first exclusion registered for a key.
  broken_environments = [CopHelper.prism_engine? ? :prism : :parser]
  broken_environments << :ruby_head if ENV['CI_RUBY_VERSION'] == 'head'
  broken_environments << :jruby if RUBY_ENGINE == 'jruby'
  broken = ->(environment) { broken_environments.include?(environment) }
  config.filter_run_excluding broken_on: broken

  # Prism supports Ruby 3.3+ parsing.
  config.filter_run_excluding unsupported_on: :prism if CopHelper.prism_engine?
end
