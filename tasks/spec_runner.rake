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
          ParallelRunner.new(rspec_args).execute
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

    # A parallel spec runner implementation, heavily inspired by
    # `TestQueue::Runner::RSpec`, but modified so that it takes an argument
    # (an array of paths of specs to run) instead of relying on ARGV.
    class ParallelRunner < ::TestQueue::Runner
      def initialize(rspec_args)
        super(Framework.new(rspec_args))
      end

      def run_worker(iterator)
        rspec = ::RSpec::Core::QueueRunner.new
        rspec.run_each(iterator).to_i
      end

      def summarize_worker(worker)
        worker.summary = worker.lines.grep(/\A\d+ examples?, /).first
        worker.failure_output = worker.output[
          /^Failures:\n\n(.*)\n^Finished/m, 1]
      end
    end

    # A TestQueue framework that is explicitly given RSpec arguments instead of
    # implicitly reading ARGV.
    class Framework < ::TestQueue::TestFramework::RSpec
      def initialize(rspec_args)
        @rspec_args = rspec_args
      end

      def all_suite_files
        options = ::RSpec::Core::ConfigurationOptions.new(@rspec_args)
        options.parse_options if options.respond_to?(:parse_options)
        options.configure(::RSpec.configuration)

        ::RSpec.configuration.files_to_run.uniq
      end
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
  desc 'Deprecated: Run RSpec code examples in parallel'
  task :spec do
    warn '`rake parallel:spec` is deprecated. Use `rake spec` instead.'
    Rake::Task[:spec].execute
  end

  desc 'Deprecated: Run RSpec code examples in parallel with ASCII encoding'
  task :ascii_spec do
    warn '`rake parallel:ascii_spec` is deprecated. Use `rake ascii_spec` ' \
         'instead.'
    Rake::Task[:ascii_spec].execute
  end
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
