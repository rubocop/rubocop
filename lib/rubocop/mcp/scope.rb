# frozen_string_literal: true

module RuboCop
  module MCP
    # What a request asks RuboCop to look at: which cops run, as `--only` and
    # `--except` choose them, and, when checking files, whether to stick to the
    # ones git says changed, as `--changed` does.
    # @api private
    class Scope
      PROPERTIES = {
        only: {
          type: 'array', items: { type: 'string' },
          description: 'Run only these cops or departments, ' \
                       'such as `Style/StringLiterals` or `Lint`.'
        },
        except: {
          type: 'array', items: { type: 'string' },
          description: 'Run every cop except these cops or departments.'
        },
        changed: {
          type: %w[boolean string],
          description: 'Check only the files git says changed: `true` for changes since the ' \
                       'last commit, or a revision to compare against, such as `main`.'
        }
      }.freeze

      # An empty list would select no cops at all rather than leave the choice
      # alone, so it counts as no list.
      #
      # @raise [RuboCop::Error] for a scope the command line would refuse
      def initialize(inline:, only: nil, except: nil, changed: nil)
        @only = only if only&.any?
        @except = except if except&.any?
        @changed = changed == true ? ChangedFiles::DEFAULT_REVISION : changed
        validate(inline)
      end

      # @return [Hash] the cop selection, among the options the LSP runtime takes
      def cop_options
        { only: @only, except: @except }.compact
      end

      def select_files(files)
        @changed ? ChangedFiles.new(@changed).filter(files) : files
      end

      private

      # Refuses what the command line refuses for the same options. Cop names
      # are left to the runner, which checks them the way `--only` does: short
      # names allowed, and only once the configuration naming a plugin's cops
      # has been loaded.
      def validate(inline)
        raise Error, '`changed` only applies when checking files.' if inline && @changed
        raise Error, '`changed` takes `true` or a git revision.' if @changed == ''

        validator = OptionsValidator.new(cop_options)
        if validator.only_includes_redundant_disable?
          raise Error, 'Lint/RedundantCopDisableDirective cannot be used with `only`.'
        end
        raise Error, 'Syntax checking cannot be turned off.' if validator.except_syntax?
      end
    end
  end
end
