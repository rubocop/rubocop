# encoding: utf-8

require 'rake'
require 'rake/tasklib'

module Rubocop
  # Provides a custom rake task.
  #
  # require 'rubocop/rake_task'
  # Rubocop::RakeTask.new
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_accessor :verbose
    attr_accessor :fail_on_error
    attr_accessor :patterns
    attr_accessor :formatters
    attr_accessor :requires
    attr_accessor :options

    def initialize(*args, &task_block)
      setup_ivars(args)

      desc 'Run RuboCop' unless ::Rake.application.last_comment

      task(name, *args) do |_, task_args|
        RakeFileUtils.send(:verbose, verbose) do
          if task_block
            task_block.call(*[self, task_args].slice(0, task_block.arity))
          end
          run_task(verbose)
        end
      end
    end

    def run_task(verbose)
      # We lazy-load rubocop so that the task doesn't dramatically impact the
      # load time of your Rakefile.
      require 'rubocop'

      cli = CLI.new
      puts 'Running RuboCop...' if verbose
      result = cli.run(full_options)
      abort('RuboCop failed!') if fail_on_error unless result == 0
    end

    private

    def full_options
      [].tap do |result|
        result.concat(formatters.map { |f| ['--format', f] }.flatten)
        result.concat(requires.map { |r| ['--require', r] }.flatten)
        result.concat(options)
        result.concat(patterns)
      end
    end

    def setup_ivars(args)
      # More lazy-loading to keep load time down.
      require 'rubocop/options'

      @name = args.shift || :rubocop
      @verbose = true
      @fail_on_error = true
      @patterns = []
      @requires = []
      @options = []
      @formatters = [Rubocop::Options::DEFAULT_FORMATTER]
    end
  end
end
