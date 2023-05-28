require_relative "../runners/rubocop"

#
# This code is based on https://github.com/standardrb/standard.
#
# Copyright (c) 2023 Test Double, Inc.
#
# The MIT License (MIT)
#
# https://github.com/standardrb/standard/blob/main/LICENSE.txt
#
module Standard
  module Lsp
    class Standardizer
      def initialize(config, logger)
        @config = config
        @logger = logger
        @rubocop_runner = Standard::Runners::Rubocop.new
      end

      # This abuses the --stdin option of rubocop and reads the formatted text
      # from the options[:stdin] that rubocop mutates. This depends on
      # parallel: false as well as the fact that rubocop doesn't otherwise dup
      # or reassign that options object. Risky business!
      #
      # Reassigning options[:stdin] is done here:
      #   https://github.com/rubocop/rubocop/blob/master/lib/rubocop/cop/team.rb#L131
      # Printing options[:stdin]
      #   https://github.com/rubocop/rubocop/blob/master/lib/rubocop/cli/command/execute_runner.rb#L95
      # Setting `parallel: true` would break this here:
      #   https://github.com/rubocop/rubocop/blob/master/lib/rubocop/runner.rb#L72
      def format(path, text)
        ad_hoc_config = fork_config(path, text, format: true)
        capture_rubocop_stdout(ad_hoc_config)
        ad_hoc_config.rubocop_options[:stdin]
      end

      def offenses(path, text)
        results = JSON.parse(
          capture_rubocop_stdout(fork_config(path, text, format: false)),
          symbolize_names: true
        )
        if results[:files].empty?
          @logger.puts_once "Ignoring file, per configuration: #{path}"
          []
        else
          results.dig(:files, 0, :offenses)
        end
      end

      private

      BASE_OPTIONS = {
        force_exclusion: true,
        parallel: false,
        todo_file: nil,
        todo_ignore_files: []
      }
      def fork_config(path, text, format:)
        options = if format
          {stdin: text, autocorrect: true, safe_autocorrect: true, formatters: []}
        else
          {stdin: text, autocorrect: false, safe_autocorrect: false, formatters: [["json"]], format: "json"}
        end
        Standard::Config.new(@config.runner, [path], BASE_OPTIONS.merge(options), @config.rubocop_config_store)
      end

      def capture_rubocop_stdout(config)
        redir = StringIO.new
        $stdout = redir
        @rubocop_runner.call(config)
        redir.string
      ensure
        $stdout = STDOUT
      end
    end
  end
end
