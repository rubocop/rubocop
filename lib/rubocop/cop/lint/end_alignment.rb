# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks whether the end keywords are aligned properly.
      #
      # Two modes are supported through the AlignWith configuration
      # parameter. If it's set to `keyword` (which is the default), the `end`
      # shall be aligned with the start of the keyword (if, class, etc.). If
      # it's set to `variable` the `end` shall be aligned with the
      # left-hand-side of the variable assignment, if there is one.
      #
      # @example
      #
      #   variable = if true
      #              end
      class EndAlignment < Cop
        include CheckAssignment
        include EndKeywordAlignment
        include IfNode

        def on_class(node)
          check_offset_of_node(node)
        end

        def on_module(node)
          check_offset_of_node(node)
        end

        def on_if(node)
          check_offset_of_node(node) unless ternary_op?(node)
        end

        def on_while(node)
          check_offset_of_node(node)
        end

        def on_until(node)
          check_offset_of_node(node)
        end

        private

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check if it's an if/unless/while/until.
          rhs = first_part_of_call_chain(rhs)

          return unless rhs

          return unless [:if, :while, :until].include?(rhs.type)
          return if ternary_op?(rhs)

          expr = node.loc.expression
          if style == :variable && !line_break_before_keyword?(expr, rhs)
            range = Parser::Source::Range.new(expr.source_buffer,
                                              expr.begin_pos,
                                              rhs.loc.keyword.end_pos)
            offset = rhs.loc.keyword.column - node.loc.expression.column
          else
            range = rhs.loc.keyword
            offset = 0
          end

          check_offset(rhs, range.source, offset)
          ignore_node(rhs) # Don't check again.
        end

        def line_break_before_keyword?(whole_expression, rhs)
          rhs.loc.keyword.line > whole_expression.line
        end

        def autocorrect(node)
          align(node,
                style == :variable ? node.each_ancestor(:lvasgn).first : node)
        end
      end
    end
  end
end
