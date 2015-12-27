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
          check_end_kw_in_node(node)
        end

        def on_module(node)
          check_end_kw_in_node(node)
        end

        def on_if(node)
          check_end_kw_in_node(node) unless ternary_op?(node)
        end

        def on_while(node)
          check_end_kw_in_node(node)
        end

        def on_until(node)
          check_end_kw_in_node(node)
        end

        def on_case(node)
          return check_asgn_alignment(node.parent, node) if argument_case?(node)
          check_end_kw_in_node(node)
        end

        private

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check if it's an if/unless/while/until.
          return unless (rhs = first_part_of_call_chain(rhs))
          return unless [:if, :while, :until, :case].include?(rhs.type)
          return if ternary_op?(rhs)

          check_asgn_alignment(node, rhs)
        end

        def check_asgn_alignment(outer_node, inner_node)
          expr = outer_node.loc.expression

          align_with = { keyword: inner_node.loc.keyword }

          if !line_break_before_keyword?(expr, inner_node)
            range = Parser::Source::Range.new(expr.source_buffer,
                                              expr.begin_pos,
                                              inner_node.loc.keyword.end_pos)
            align_with[:variable] = range
          end

          check_end_kw_alignment(inner_node, align_with)
          ignore_node(inner_node) # Don't check again.
        end

        def autocorrect(node)
          align(node, alignment_node(node))
        end

        def alignment_node(node)
          return node unless style == :variable
          return node.parent if argument_case?(node)

          node.each_ancestor(:lvasgn).first
        end

        def argument_case?(node)
          node.case_type? && node.parent && node.parent.send_type?
        end
      end
    end
  end
end
