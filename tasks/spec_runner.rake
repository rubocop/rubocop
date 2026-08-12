# frozen_string_literal: true

require_relative '../spec/support/encoding_helper'
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
    include EncodingHelper

    attr_reader :rspec_args

    def initialize(rspec_args = %w[spec --force-color], parallel: true,
                   external_encoding: 'UTF-8', internal_encoding: nil)
      @rspec_args = ENV['GITHUB_ACTIONS'] == 'true' ? %w[spec --no-color] : rspec_args

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

    def with_encoding(&block)
      with_default_external_encoding(@temporary_external_encoding) do
        with_default_internal_encoding(@temporary_internal_encoding, &block)
      end
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
    class ParallelRunner < TestQueue::Runner
      SUMMARY_REGEXP = /(?<=# SUMMARY BEGIN\n).*(?=\n# SUMMARY END)/m.freeze
      FAILURE_OUTPUT_REGEXP = /(?<=# FAILURES BEGIN\n\n).*(?=# FAILURES END)/m.freeze
      RERUN_REGEXP = /(?<=# RERUN BEGIN\n).+(?=\n# RERUN END)/m.freeze
      THREAD_DUMP_SIGNAL = 'USR2'

      def initialize(rspec_args)
        super(Framework.new(rspec_args))

        @exit_when_done = false
        @failure_count = 0
        @stall_watchdog = nil
      end

      # The test-queue master produces no output between startup and the final summary,
      # so a single stuck worker (or a stuck suite discovery process) hangs the whole run
      # silently until an external timeout kills the job, leaving no clue about where it
      # was stuck. The watchdog turns such a hang into a fast failure that reports what
      # every process was doing.
      def execute_internal
        install_thread_dump_signal_handler
        start_stall_watchdog
        super
      ensure
        stop_stall_watchdog
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
        # A worker without an exit status was killed by a signal (the stall watchdog,
        # the kernel OOM killer, ...), so its failures never reach the summary regexps
        # and its raw output is the only trace left.
        puts worker.output if worker.status.exitstatus.nil?
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

      # Installed in the master before forking so that the suite discovery
      # process and all workers inherit it. The handler writes to `STDOUT`
      # rather than `$stdout` because specs may temporarily replace `$stdout`,
      # while each worker's `STDOUT` is reopened to the output file that the
      # master collects.
      def install_thread_dump_signal_handler
        Signal.trap(THREAD_DUMP_SIGNAL) do
          # rubocop:disable Style/GlobalStdStream -- Specs may replace $stdout with a StringIO.
          STDOUT.write(thread_dump)
          STDOUT.flush
          # rubocop:enable Style/GlobalStdStream
        end
      end

      def thread_dump
        lines = ["=== Thread dump for pid #{Process.pid} (#{$PROGRAM_NAME}) ==="]

        Thread.list.each do |thread|
          lines << "--- #{thread.inspect} ---"
          lines.concat(thread.backtrace || ['(no backtrace)'])
        end

        "#{lines.join("\n")}\n"
      end

      def start_stall_watchdog
        return unless (deadline_minutes = stall_deadline_minutes)

        @stall_watchdog = Thread.new do
          # Runs taking longer than the deadline are considered stalled.
          sleep(deadline_minutes * 60)

          handle_stall(deadline_minutes)
        end
      end

      def stall_deadline_minutes
        deadline = ENV.fetch('RUBOCOP_SPEC_RUNNER_DEADLINE', nil)
        if deadline
          minutes = deadline.to_f

          return minutes.positive? ? minutes : nil
        end

        # A parallel spec run normally takes a few minutes, so a run exceeding this deadline on CI
        # is considered stalled. Keep the deadline well below the job-level `timeout-minutes` in
        # the CI workflow, so that the watchdog dumps its diagnostics before the job is killed.
        # There is no default deadline elsewhere so that slow development machines are not killed.
        return 15.0 if ENV['GITHUB_ACTIONS'] == 'true'

        nil
      end

      def handle_stall(deadline_minutes)
        puts "The spec run did not finish within #{deadline_minutes} minutes; assuming it stalled."
        report_master_state
        puts thread_dump
        request_child_thread_dumps

        # Give the signaled processes time to write their thread dumps before they are killed.
        sleep(15)

        kill_stalled_processes
      end

      def report_master_state
        puts "Suites still queued: #{@queue.size}"

        if @discovering_suites_pid
          puts "Suite discovery process #{@discovering_suites_pid} is still running."
        end

        @workers.each do |pid, worker|
          suite_name, path = last_assignment(pid)
          assignment = suite_name ? "#{suite_name} (#{path})" : 'with no assigned suite'
          puts "Worker [#{worker.num}] (pid #{pid}) is still running: #{assignment}"
        end
      end

      def last_assignment(pid)
        # `@assignments` maps a suite to the worker it was handed to. Hash insertion order makes
        # the last matching entry the most recently assigned suite, i.e. the one the worker is
        # likely stuck in.
        assignment = @assignments.to_a.reverse_each.find do |_suite, (_host, assigned_pid)|
          assigned_pid == pid
        end
        return if assignment.nil?

        assignment.first
      end

      def request_child_thread_dumps
        stalled_process_ids.each do |pid|
          Process.kill(THREAD_DUMP_SIGNAL, pid)
        rescue Errno::ESRCH
          nil
        end
      end

      # SIGKILL rather than SIGTERM: a process stuck in a tight loop or a deadlock cannot be trusted
      # to honor a catchable signal. Killing the workers also unblocks the master's final blocking
      # reap, and killed workers count as failures in the summary, so the run exits non-zero.
      def kill_stalled_processes
        stalled_process_ids.each do |pid|
          Process.kill('KILL', pid)
        rescue Errno::ESRCH
          nil
        end
      end

      def stalled_process_ids
        ([@discovering_suites_pid] + @workers.keys).compact
      end

      def stop_stall_watchdog
        @stall_watchdog&.kill
      end

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
    class Framework < TestQueue::TestFramework::RSpec
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

desc 'Run RSpec code examples with Prism'
task :prism_spec do
  sh('PARSER_ENGINE=parser_prism bundle exec rake spec')
end
