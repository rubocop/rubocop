# frozen_string_literal: true

# Require this file to load code that supports testing using RSpec.

require_relative 'cop_helper'
require_relative 'host_environment_simulation_helper'
require_relative 'expect_offense'
require_relative 'shared_contexts'
require_relative 'stub_cop'

RSpec.configure do |config|
  config.include CopHelper
  config.include RuboCop::RSpec::ExpectOffense
  config.include RuboCop::RSpec::StubCop
  config.include HostEnvironmentSimulatorHelper
end
