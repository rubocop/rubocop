# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for method signatures that span multiple lines.
      #
      # @example
      #
      #   # good
      #
      #   def foo(bar, baz)
      #   end
      #
      #   # bad
      #
      #   def foo(bar,
      #           baz)
      #   end
      #
      class MultilineMethodSignature < Cop
        MSG = 'Avoid multi-line method signatures.'

        def on_def(node)
          return unless node.arguments?
          return if opening_line(node) == closing_line(node)
          return if correction_exceeds_max_line_length?(node)

          add_offense(node)
        end
        alias on_defs on_def

        private

        def opening_line(node)
          node.first_line
        end

        def closing_line(node)
          node.arguments.last_line
        end

        def correction_exceeds_max_line_length?(node)
          indentation_width(node) + definition_width(node) > max_line_length
        end

        def indentation_width(node)
          processed_source.line_indentation(node.loc.expression.line)
        end

        def definition_width(node)
          node.source_range.begin.join(node.arguments.source_range.end).length
        end

        def max_line_length
          config.for_cop('Layout/LineLength')['Max'] || 80
        end
      end
    end
  end
end
