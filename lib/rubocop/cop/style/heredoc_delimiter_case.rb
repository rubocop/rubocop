# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that your heredocs are using the configured case.
      # By default it is configured to enforce uppercase heredocs.
      #
      # @example
      #
      #   # EnforcedStyle: uppercase (default)
      #
      #   # good
      #   <<-SQL
      #     SELECT * FROM foo
      #   SQL
      #
      #   # bad
      #   <<-sql
      #     SELECT * FROM foo
      #   sql
      #
      # @example
      #
      #   # EnforcedStyle: lowercase
      #
      #   # good
      #   <<-sql
      #     SELECT * FROM foo
      #   sql
      #
      #   # bad
      #   <<-SQL
      #     SELECT * FROM foo
      #   SQL
      class HeredocDelimiterCase < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use %s heredoc delimiters.'.freeze
        OPENING_DELIMITER = /<<[~-]?'?(\w+)'?\b/

        def on_str(node)
          return unless heredoc?(node) && !correct_case_delimiters?(node)

          add_offense(node, :heredoc_end)
        end
        alias on_dstr on_str
        alias on_xstr on_str

        private

        def message(_node)
          format(MSG, style)
        end

        def heredoc?(node)
          node.loc.is_a?(Parser::Source::Map::Heredoc)
        end

        def correct_case_delimiters?(node)
          delimiters(node) == correct_delimiters(node)
        end

        def correct_delimiters(node)
          if style == :uppercase
            delimiters(node).upcase
          else
            delimiters(node).downcase
          end
        end

        def delimiters(node)
          node.source.match(OPENING_DELIMITER).captures.first
        end
      end
    end
  end
end
