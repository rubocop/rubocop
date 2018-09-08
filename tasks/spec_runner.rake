# frozen_string_literal: true

require 'rspec/core'
require 'test_queue'
require 'test_queue/runner/rspec'

module RuboCop
  # Helper for executing a code block with a temporary external encoding.
  # This is a bit risky, since strings defined before the block may have a
  # different encoding than strings defined inside the block.
  class SpecRunner
    def initialize(encoding: 'UTF-8')
      @previous_encoding = Encoding.default_external
      @temporary_encoding = encoding
    end

    def with_encoding
      Encoding.default_external = @temporary_encoding
      yield
    ensure
      Encoding.default_external = @previous_encoding
    end
  end
end

desc 'Run RSpec code examples'
task :spec do
  RuboCop::SpecRunner.new.with_encoding do
    RSpec::Core::Runner.run(%w[spec])
  end
end

desc 'Run RSpec code examples with ASCII encoding'
task :ascii_spec do
  RuboCop::SpecRunner.new(encoding: 'ASCII').with_encoding do
    RSpec::Core::Runner.run(%w[spec])
  end
end

namespace :parallel do
  desc 'Run RSpec code examples in parallel'
  task :spec do
    RuboCop::SpecRunner.new.with_encoding do
      ARGV = %w[spec]
      TestQueue::Runner::RSpec.new.execute
    end
  end

  desc 'Run RSpec code examples in parallel with ASCII encoding'
  task :ascii_spec do
    RuboCop::SpecRunner.new(encoding: 'ASCII').with_encoding do
      ARGV = %w[spec]
      TestQueue::Runner::RSpec.new.execute
    end
  end
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
