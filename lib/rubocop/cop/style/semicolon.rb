# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for multiple expressions placed on the same line.
      # It also checks for lines terminated with a semicolon.
      #
      # @example
      #   # bad
      #   foo = 1; bar = 2;
      #   baz = 3;
      #
      #   # good
      #   foo = 1
      #   bar = 2
      #   baz = 3
      class Semicolon < Cop
        MSG = 'Do not use semicolons to terminate expressions.'.freeze

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source

          check_for_line_terminator_or_opener
        end

        def on_begin(node)
          return if cop_config['AllowAsExpressionSeparator']
          exprs = node.children

          return if exprs.size < 2

          # create a map matching lines to the number of expressions on them
          exprs_lines = exprs.map { |e| e.source_range.line }
          lines = exprs_lines.group_by { |i| i }

          # every line with more than 1 expression on it is an offense
          lines.each do |line, expr_on_line|
            next unless expr_on_line.size > 1
            # TODO: Find the correct position of the semicolon. We don't know
            # if the first semicolon on the line is a separator of
            # expressions. It's just a guess.
            column = @processed_source[line - 1].index(';')
            convention_on(line, column, false)
          end
        end

        private

        def check_for_line_terminator_or_opener
          each_semicolon { |line, column| convention_on(line, column, true) }
        end

        def each_semicolon
          tokens_for_lines.each do |line, tokens|
            yield line, tokens.last.column if tokens.last.semicolon?
            yield line, tokens.first.column if tokens.first.semicolon?
          end
        end

        def tokens_for_lines
          @processed_source.tokens.group_by(&:line)
        end

        def convention_on(line, column, autocorrect)
          range = source_range(@processed_source.buffer, line, column)
          # Don't attempt to autocorrect if semicolon is separating statements
          # on the same line
          add_offense(autocorrect ? range : nil, location: range)
        end

        def autocorrect(range)
          return unless range
          ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
