# frozen_string_literal: true

require 'rspec/core'
require 'test_queue'
require 'test_queue/runner/rspec'

module RuboCop
  # Helper for running specs with a temporary external encoding.
  # This is a bit risky, since strings defined before the block may have a
  # different encoding than strings defined inside the block.
  # The specs will be run in parallel if the system implements `fork`.
  class SpecRunner
    def initialize(encoding: 'UTF-8')
      @previous_encoding = Encoding.default_external
      @temporary_encoding = encoding
    end

    def run_specs
      rspec_args = %w[spec]
      with_encoding do
        if Process.respond_to?(:fork)
          ARGV.clear
          ARGV.concat(rspec_args)
          ::TestQueue::Runner::RSpec.new.execute
        else
          ::RSpec::Core::Runner.run(rspec_args)
        end
      end
    end

    private

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
  RuboCop::SpecRunner.new.run_specs
end

desc 'Run RSpec code examples with ASCII encoding'
task :ascii_spec do
  RuboCop::SpecRunner.new(encoding: 'ASCII').run_specs
end

namespace :parallel do
  desc 'Run RSpec code examples in parallel'
  task :spec do
    RuboCop::SpecRunner.new.run_specs
  end

  desc 'Run RSpec code examples in parallel with ASCII encoding'
  task :ascii_spec do
    RuboCop::SpecRunner.new(encoding: 'ASCII').run_specs
  end
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
