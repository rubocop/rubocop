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
      class MultilineMethodSignature < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Avoid multi-line method signatures.'

        def on_def(node)
          return unless node.arguments?
          return if opening_line(node) == closing_line(node)
          return if correction_exceeds_max_line_length?(node)

          add_offense(node) { |corrector| autocorrect(corrector, node) }
        end
        alias on_defs on_def

        private

        def autocorrect(corrector, node)
          arguments = node.arguments
          joined_arguments = arguments.map(&:source).join(', ')
          last_line_source_of_arguments = last_line_source_of_arguments(arguments)

          if last_line_source_of_arguments.start_with?(')')
            joined_arguments = "#{joined_arguments}#{last_line_source_of_arguments}"

            corrector.remove(range_by_whole_lines(arguments.loc.end, include_final_newline: true))
          end

          corrector.remove(arguments_range(node))
          corrector.insert_after(arguments.loc.begin, joined_arguments)
        end

        def last_line_source_of_arguments(arguments)
          processed_source[arguments.last_line - 1].strip
        end

        def arguments_range(node)
          range = range_between(
            node.first_argument.source_range.begin_pos, node.last_argument.source_range.end_pos
          )

          range_with_surrounding_space(range: range, side: :left)
        end

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
          config.for_cop('Layout/LineLength')['Max'] || 120
        end
      end
    end
  end
end
