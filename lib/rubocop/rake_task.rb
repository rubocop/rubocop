# frozen_string_literal: true

require 'rake'
require 'rake/tasklib'

module RuboCop
  # Provides a custom rake task.
  #
  # require 'rubocop/rake_task'
  # RuboCop::RakeTask.new
  #
  # Use global Rake namespace here to avoid namespace issues with custom
  # rubocop-rake tasks
  class RakeTask < ::Rake::TaskLib
    attr_accessor :name, :verbose, :fail_on_error, :patterns, :formatters, :requires, :options

    def initialize(name = :rubocop, *args, &task_block)
      setup_ivars(name)

      desc 'Run RuboCop' unless ::Rake.application.last_description

      task(name, *args) do |_, task_args|
        RakeFileUtils.verbose(verbose) do
          yield(*[self, task_args].slice(0, task_block.arity)) if block_given?
          run_cli(verbose, full_options)
        end
      end

      setup_subtasks(name, *args, &task_block)
    end

    private

    def run_cli(verbose, options)
      # We lazy-load rubocop so that the task doesn't dramatically impact the
      # load time of your Rakefile.
      require 'rubocop'

      cli = CLI.new
      puts 'Running RuboCop...' if verbose
      result = cli.run(options)
      abort('RuboCop failed!') if result.nonzero? && fail_on_error
    end

    def full_options
      formatters.map { |f| ['--format', f] }.flatten
                .concat(requires.map { |r| ['--require', r] }.flatten)
                .concat(options.flatten)
                .concat(patterns)
    end

    def setup_ivars(name)
      @name = name
      @verbose = true
      @fail_on_error = true
      @patterns = []
      @requires = []
      @options = []
      @formatters = []
    end

    def setup_subtasks(name, *args, &task_block)
      namespace(name) do
        desc 'Auto-correct RuboCop offenses'

        task(:auto_correct, *args) do |_, task_args|
          RakeFileUtils.verbose(verbose) do
            yield(*[self, task_args].slice(0, task_block.arity)) if block_given?
            options = full_options.unshift('--auto-correct-all')
            options.delete('--parallel')
            run_cli(verbose, options)
          end
        end
      end
    end
  end
end
