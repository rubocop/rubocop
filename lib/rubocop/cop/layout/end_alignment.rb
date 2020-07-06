# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks whether the end keywords are aligned properly.
      #
      # Three modes are supported through the `EnforcedStyleAlignWith`
      # configuration parameter:
      #
      # If it's set to `keyword` (which is the default), the `end`
      # shall be aligned with the start of the keyword (if, class, etc.).
      #
      # If it's set to `variable` the `end` shall be aligned with the
      # left-hand-side of the variable assignment, if there is one.
      #
      # If it's set to `start_of_line`, the `end` shall be aligned with the
      # start of the line where the matching keyword appears.
      #
      # @example EnforcedStyleAlignWith: keyword (default)
      #   # bad
      #
      #   variable = if true
      #       end
      #
      #   # good
      #
      #   variable = if true
      #              end
      #
      #   variable =
      #     if true
      #     end
      #
      # @example EnforcedStyleAlignWith: variable
      #   # bad
      #
      #   variable = if true
      #       end
      #
      #   # good
      #
      #   variable = if true
      #   end
      #
      #   variable =
      #     if true
      #     end
      #
      # @example EnforcedStyleAlignWith: start_of_line
      #   # bad
      #
      #   variable = if true
      #       end
      #
      #   puts(if true
      #        end)
      #
      #   # good
      #
      #   variable = if true
      #   end
      #
      #   puts(if true
      #   end)
      #
      #   variable =
      #     if true
      #     end
      class EndAlignment < Cop
        include CheckAssignment
        include EndKeywordAlignment
        include RangeHelp

        def on_class(node)
          check_other_alignment(node)
        end

        def on_module(node)
          check_other_alignment(node)
        end

        def on_if(node)
          check_other_alignment(node) unless node.ternary?
        end

        def on_while(node)
          check_other_alignment(node)
        end

        def on_until(node)
          check_other_alignment(node)
        end

        def on_case(node)
          if node.argument?
            check_asgn_alignment(node.parent, node)
          else
            check_other_alignment(node)
          end
        end

        def autocorrect(node)
          AlignmentCorrector.align_end(processed_source,
                                       node,
                                       alignment_node(node))
        end

        private

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check if it's an if/unless/while/until.
          return unless (rhs = first_part_of_call_chain(rhs))
          return unless rhs.conditional?
          return if rhs.if_type? && rhs.ternary?

          check_asgn_alignment(node, rhs)
        end

        def check_asgn_alignment(outer_node, inner_node)
          align_with = {
            keyword: inner_node.loc.keyword,
            start_of_line: start_line_range(inner_node),
            variable: asgn_variable_align_with(outer_node, inner_node)
          }

          check_end_kw_alignment(inner_node, align_with)
          ignore_node(inner_node)
        end

        def asgn_variable_align_with(outer_node, inner_node)
          expr = outer_node.source_range

          if !line_break_before_keyword?(expr, inner_node)
            range_between(expr.begin_pos, inner_node.loc.keyword.end_pos)
          else
            inner_node.loc.keyword
          end
        end

        def check_other_alignment(node)
          align_with = {
            keyword: node.loc.keyword,
            variable: node.loc.keyword,
            start_of_line: start_line_range(node)
          }
          check_end_kw_alignment(node, align_with)
        end

        def alignment_node(node)
          case style
          when :keyword
            node
          when :variable
            alignment_node_for_variable_style(node)
          else
            start_line_range(node)
          end
        end

        def alignment_node_for_variable_style(node)
          return node.parent if node.case_type? && node.argument?

          assignment = node.ancestors.find(&:assignment_or_similar?)
          if assignment && !line_break_before_keyword?(assignment.source_range,
                                                       node)
            assignment
          else
            # Fall back to 'keyword' style if this node is not on the RHS of an
            # assignment, or if it is but there's a line break between LHS and
            # RHS.
            node
          end
        end

        def start_line_range(node)
          expr   = node.source_range
          buffer = expr.source_buffer
          source = buffer.source_line(expr.line)
          range  = buffer.line_range(expr.line)

          range_between(range.begin_pos + (source =~ /\S/),
                        range.begin_pos + (source =~ /\s*\z/))
        end
      end
    end
  end
end
