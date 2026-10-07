# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Checks that your heredocs are using meaningful delimiters.
      # By default it disallows `END` and `EO*`, and can be configured through
      # forbidden listing additional delimiters.
      #
      # @example
      #
      #   # good
      #   <<-SQL
      #     SELECT * FROM foo
      #   SQL
      #
      #   # bad
      #   <<-END
      #     SELECT * FROM foo
      #   END
      #
      #   # bad
      #   <<-EOS
      #     SELECT * FROM foo
      #   EOS
      class HeredocDelimiterNaming < Base
        include Heredoc

        MSG = 'Use meaningful heredoc delimiters.'

        def on_heredoc(node)
          return if meaningful_delimiters?(node)

          range = node.children.empty? ? node : node.loc.heredoc_end

          add_offense(range)
        end

        private

        def meaningful_delimiters?(node)
          delimiters = delimiter_string(node)

          return false unless /\w/.match?(delimiters)

          forbidden_delimiter_regexps.none? { |regexp| regexp.match?(delimiters) }
        end

        def forbidden_delimiter_regexps
          @forbidden_delimiter_regexps ||= forbidden_delimiters.map { |d| Regexp.new(d) }
        end

        def forbidden_delimiters
          cop_config['ForbiddenDelimiters'] || []
        end
      end
    end
  end
end
