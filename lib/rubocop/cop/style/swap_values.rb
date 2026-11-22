# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces the use of shorthand-style swapping of 2 variables.
      #
      # @safety
      #   Autocorrection is unsafe, because the temporary variable used to
      #   swap variables will be removed, but may be referred to elsewhere.
      #
      # @example
      #   # bad
      #   tmp = x
      #   x = y
      #   y = tmp
      #
      #   # good
      #   x, y = y, x
      #
      class SwapValues < Base
        extend AutoCorrector

        MSG = 'Replace this and assignments at lines %<x_line>d ' \
              'and %<y_line>d with `%<replacement>s`.'

        SIMPLE_ASSIGNMENT_TYPES = %i[lvasgn ivasgn cvasgn gvasgn casgn].to_set.freeze

        def on_asgn(node)
          return unless node.parent&.type?(:begin, :kwbegin)

          tmp_assign = node
          x_assign, y_assign = *node.right_siblings.take(2)
          return unless x_assign && y_assign && swapping_values?(tmp_assign, x_assign, y_assign)

          add_offense(node, message: message(x_assign, y_assign)) do |corrector|
            range = tmp_assign.source_range.join(y_assign.source_range)
            next if contains_comment_or_heredoc?(range)

            corrector.replace(range, replacement(x_assign))
          end
        end

        SIMPLE_ASSIGNMENT_TYPES.each { |asgn_type| alias_method :"on_#{asgn_type}", :on_asgn }

        private

        def swapping_values?(tmp_assign, x_assign, y_assign)
          simple_assignment?(tmp_assign) &&
            simple_assignment?(x_assign) &&
            simple_assignment?(y_assign) &&
            lhs(x_assign) == rhs(tmp_assign) &&
            lhs(y_assign) == rhs(x_assign) &&
            rhs(y_assign) == lhs(tmp_assign)
        end

        def contains_comment_or_heredoc?(range)
          processed_source.tokens_within(range).any? do |token|
            token.comment? || token.type == :tSTRING_END
          end
        end

        def simple_assignment?(node)
          return false unless node.respond_to?(:type)

          SIMPLE_ASSIGNMENT_TYPES.include?(node.type)
        end

        def message(x_assign, y_assign)
          format(
            MSG,
            x_line: x_assign.first_line,
            y_line: y_assign.first_line,
            replacement: replacement(x_assign)
          )
        end

        def replacement(x_assign)
          x = lhs(x_assign)
          y = rhs(x_assign)
          "#{x}, #{y} = #{y}, #{x}"
        end

        def lhs(node)
          if node.casgn_type?
            "#{'::' if node.absolute?}#{node.const_name}"
          else
            node.name.to_s
          end
        end

        def rhs(node)
          node.expression.source
        end
      end
    end
  end
end
