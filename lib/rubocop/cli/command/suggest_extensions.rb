# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Suggest RuboCop extensions to install based on Gemfile dependencies.
      # Only primary dependencies are evaluated, so if a dependency depends on a
      # gem with an extension, it is not suggested. However, if an extension is
      # a transitive dependency, it will not be suggested.
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

          extensions.sort.each do |extension|
            puts "  * #{extension} (https://github.com/rubocop/#{extension})"
          end

          puts
          puts 'You can opt out of this message by adding the following to your config '\
            '(see https://docs.rubocop.org/rubocop/extensions.html#extension-suggestions '\
            'for more options):'
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
            @options[:only] || @options[:debug] || @options[:list_target_files] ||
            @options[:out] || @options[:stdin] ||
            !INCLUDED_FORMATTERS.include?(current_formatter)
        end

        def current_formatter
          @options[:format] || @config_store.for_pwd.for_all_cops['DefaultFormatter'] || 'p'
        end

        def extensions
          return [] unless lockfile.dependencies.any?

          extensions = @config_store.for_pwd.for_all_cops['SuggestExtensions'] || {}
          extensions.select { |_, v| (Array(v) & dependent_gems).any? }.keys - installed_gems
        end

        def lockfile
          @lockfile ||= Lockfile.new
        end

        def dependent_gems
          lockfile.dependencies.map(&:name)
        end

        def installed_gems
          lockfile.gems.map(&:name)
        end

        def puts(*args)
          output = (@options[:stderr] ? $stderr : $stdout)
          output.puts(*args)
        end
      end
    end
  end
end
