# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks the indentation of the right hand side operand in
      # binary operations that span more than one line.
      #
      # @example
      #   # bad
      #   if a +
      #   b
      #     something
      #   end
      class MultilineOperationIndentation < Cop
        include ConfigurableEnforcedStyle
        include AutocorrectAlignment
        include MultilineExpressionIndentation

        def on_and(node)
          check_and_or(node)
        end

        def on_or(node)
          check_and_or(node)
        end

        def validate_config
          if style == :aligned && cop_config['IndentationWidth']
            fail ValidationError, 'The `Style/MultilineOperationIndentation`' \
                                  ' cop only accepts an `IndentationWidth` ' \
                                  'configuration parameter when ' \
                                  '`EnforcedStyle` is `indented`.'
          end
        end

        private

        def relevant_node?(node)
          !node.loc.dot # Don't check method calls with dot operator.
        end

        def check_and_or(node)
          lhs, rhs = *node
          range = offending_range(node, lhs, rhs.source_range, style)
          check(range, node, lhs, rhs.source_range)
        end

        def offending_range(node, lhs, rhs, given_style)
          return false unless begins_its_line?(rhs)
          return false if lhs.loc.line == rhs.line # Needed for unary op.
          return false if not_for_this_cop?(node)

          correct_column = if should_align?(node, rhs, given_style)
                             lhs.loc.column
                           else
                             indentation(lhs) + correct_indentation(node)
                           end
          @column_delta = correct_column - rhs.column
          rhs if @column_delta != 0
        end

        def should_align?(node, rhs, given_style)
          given_style == :aligned && (kw_node_with_special_indentation(node) ||
                                      part_of_assignment_rhs(node, rhs) ||
                                      argument_in_method_call(node))
        end

        def message(node, lhs, rhs)
          what = operation_description(node, rhs)
          if should_align?(node, rhs, style)
            "Align the operands of #{what} spanning multiple lines."
          else
            used_indentation = rhs.column - indentation(lhs)
            "Use #{correct_indentation(node)} (not #{used_indentation}) " \
              "spaces for indenting #{what} spanning multiple lines."
          end
        end
      end
    end
  end
end
