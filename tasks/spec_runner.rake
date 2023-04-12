# frozen_string_literal: true

require 'rspec/core'
require 'test_queue'
require 'test_queue/runner/rspec'

module TestQueue
  # Add `failed_examples` into `TestQueue::Worker` so we can keep
  # track of the output for re-running failed examples from RSpec.
  class Worker
    attr_accessor :failed_examples
  end
end

module RuboCop
  # Helper for running specs with a temporary external encoding.
  # This is a bit risky, since strings defined before the block may have a
  # different encoding than strings defined inside the block.
  # The specs will be run in parallel if the system implements `fork`.
  # If ENV['COVERAGE'] is truthy, code coverage will be measured.
  class SpecRunner
    attr_reader :rspec_args

    def initialize(rspec_args = %w[spec --force-color], parallel: true,
                   external_encoding: 'UTF-8', internal_encoding: nil)
      @rspec_args = ENV['GITHUB_ACTIONS'] == 'true' ? %w[spec --no-color] : rspec_args
      @previous_external_encoding = Encoding.default_external
      @previous_internal_encoding = Encoding.default_internal

      @temporary_external_encoding = external_encoding
      @temporary_internal_encoding = internal_encoding
      @parallel = parallel
    end

    def run_specs
      n_failures = with_encoding do
        if @parallel && Process.respond_to?(:fork)
          parallel_runner_klass.new(rspec_args).execute
        else
          ::RSpec::Core::Runner.run(rspec_args)
        end
      end

      exit!(n_failures) unless n_failures.zero?
    end

    private

    def with_encoding
      Encoding.default_external = @temporary_external_encoding
      Encoding.default_internal = @temporary_internal_encoding
      yield
    ensure
      Encoding.default_external = @previous_external_encoding
      Encoding.default_internal = @previous_internal_encoding
    end

    def parallel_runner_klass
      if ENV['COVERAGE']
        ParallelCoverageRunner
      else
        ParallelRunner
      end
    end

    # A parallel spec runner implementation, heavily inspired by
    # `TestQueue::Runner::RSpec`, but modified so that it takes an argument
    # (an array of paths of specs to run) instead of relying on ARGV.
    class ParallelRunner < ::TestQueue::Runner
      SUMMARY_REGEXP = /(?<=# SUMMARY BEGIN\n).*(?=\n# SUMMARY END)/m.freeze
      FAILURE_OUTPUT_REGEXP = /(?<=# FAILURES BEGIN\n\n).*(?=# FAILURES END)/m.freeze
      RERUN_REGEXP = /(?<=# RERUN BEGIN\n).+(?=\n# RERUN END)/m.freeze

      def initialize(rspec_args)
        super(Framework.new(rspec_args))

        @exit_when_done = false
        @failure_count = 0
      end

      def run_worker(iterator)
        rspec = ::RSpec::Core::QueueRunner.new
        rspec.run_each(iterator).to_i
      end

      # Override `TestQueue::Runner#worker_completed` to not output anything
      # as it adds a lot of noise by default
      def worker_completed(worker)
        return if @aborting

        @completed << worker
      end

      def summarize_worker(worker)
        worker.summary = worker.output[SUMMARY_REGEXP]
        worker.failure_output = update_count(worker.output[FAILURE_OUTPUT_REGEXP])
        worker.failed_examples = worker.output[RERUN_REGEXP]
      end

      def summarize_internal
        ret = super

        unless @failures.blank?
          puts "==> Failed Examples\n\n"
          puts @completed.filter_map(&:failed_examples).sort.join("\n")
          puts
        end

        ret
      end

      private

      def update_count(failures)
        # The ParallelFormatter formatter doesn't try to count failures, but
        # prefixes each with `*)`, so that they can be updated to count failures
        # globally once all workers have completed.

        return unless failures

        failures.gsub('*)') { "#{@failure_count += 1})" }
      end
    end

    # A custom runner for measuring code coverage in parallel.
    class ParallelCoverageRunner < ParallelRunner
      def after_fork(num)
        SimpleCov.command_name "rspec-#{num}"
      end

      def cleanup_worker
        SimpleCov.result
      end

      def summarize
        SimpleCov.at_exit.call
      end
    end

    # A TestQueue framework that is explicitly given RSpec arguments instead of
    # implicitly reading ARGV.
    class Framework < ::TestQueue::TestFramework::RSpec
      def initialize(rspec_args)
        super()
        formatter_args = %w[
          --require ./lib/rubocop/rspec/parallel_formatter.rb
          --format RuboCop::RSpec::ParallelFormatter
        ]
        @rspec_args = rspec_args.concat(formatter_args)
      end

      def all_suite_files
        options = ::RSpec::Core::ConfigurationOptions.new(@rspec_args)
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
  RuboCop::SpecRunner.new(external_encoding: 'ASCII').run_specs
end
