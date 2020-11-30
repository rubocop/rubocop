# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Run all the selected cops and report the result.
      # @api private
      class SuggestExtensions < Base
        # Combination of short and long formatter names.
        INCLUDED_FORMATTERS = %w[p progress fu fuubar pa pacman].freeze

        self.command_name = :suggest_extensions

        def run
          return if skip? || extensions.none?

          puts
          puts 'Tip: Based on detected gems, the following '\
            'RuboCop extension libraries might be helpful:'

          extensions.each do |extension|
            puts "  * #{extension} (http://github.com/rubocop-hq/#{extension})"
          end

          puts
          puts 'You can opt out of this message by adding the following to your config:'
          puts '  AllCops:'
          puts '    SuggestExtensions: false'
          puts if @options[:display_time]
        end

        private

        def skip?
          # Disable outputting the notification:
          # 1. On CI
          # 2. When given RuboCop options that it doesn't make sense for
          # 3. For all formatters except specified in `INCLUDED_FORMATTERS'`
          ENV['CI'] ||
            @options[:only] || @options[:debug] || @options[:list_target_files] || @options[:out] ||
            !INCLUDED_FORMATTERS.include?(current_formatter)
        end

        def current_formatter
          @options[:format] || @config_store.for_pwd.for_all_cops['DefaultFormatter'] || 'p'
        end

        def extensions
          extensions = @config_store.for_pwd.for_all_cops['SuggestExtensions']
          return [] unless extensions

          extensions.select { |_, v| (v & dependent_gems).any? }.keys - dependent_gems
        end

        def dependent_gems
          # This only includes gems in Gemfile, not in lockfile
          Bundler.load.dependencies.map(&:name)
        end

        def puts(*args)
          output = (@options[:stderr] ? $stderr : $stdout)
          output.puts(*args)
        end
      end
    end
  end
end
