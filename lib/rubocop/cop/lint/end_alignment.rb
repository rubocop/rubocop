# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
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
      # @example
      #
      #   # bad
      #
      #   variable = if true
      #       end
      #
      # @example
      #
      #   # EnforcedStyleAlignWith: keyword (default)
      #
      #   # good
      #
      #   variable = if true
      #              end
      #
      # @example
      #
      #   # EnforcedStyleAlignWith: variable
      #
      #   # good
      #
      #   variable = if true
      #   end
      #
      # @example
      #
      #   # EnforcedStyleAlignWith: start_of_line
      #
      #   # good
      #
      #   puts(if true
      #   end)
      class EndAlignment < Cop
        include CheckAssignment
        include EndKeywordAlignment
        include IfNode

        def on_class(node)
          check_other_alignment(node)
        end

        def on_module(node)
          check_other_alignment(node)
        end

        def on_if(node)
          check_other_alignment(node) unless ternary?(node)
        end

        def on_while(node)
          check_other_alignment(node)
        end

        def on_until(node)
          check_other_alignment(node)
        end

        def on_case(node)
          return check_asgn_alignment(node.parent, node) if argument_case?(node)
          check_other_alignment(node)
        end

        private

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check if it's an if/unless/while/until.
          return unless (rhs = first_part_of_call_chain(rhs))
          return unless [:if, :while, :until, :case].include?(rhs.type)
          return if ternary?(rhs)

          check_asgn_alignment(node, rhs)
        end

        def check_asgn_alignment(outer_node, inner_node)
          expr = outer_node.source_range

          align_with = {
            keyword: inner_node.loc.keyword,
            start_of_line: start_line_range(outer_node)
          }

          align_with[:variable] =
            if !line_break_before_keyword?(expr, inner_node)
              range_between(expr.begin_pos, inner_node.loc.keyword.end_pos)
            else
              inner_node.loc.keyword
            end

          check_end_kw_alignment(inner_node, align_with)
          ignore_node(inner_node) # Don't check again.
        end

        def check_other_alignment(node)
          align_with = {
            keyword: node.loc.keyword,
            variable: node.loc.keyword,
            start_of_line: start_line_range(node)
          }
          check_end_kw_alignment(node, align_with)
        end

        def autocorrect(node)
          align(node, alignment_node(node))
        end

        def alignment_node(node)
          if style == :keyword
            node
          elsif style == :variable
            return node.parent if argument_case?(node)
            # Fall back to 'keyword' style if this node is not on the RHS
            # of an assignment
            node.ancestors.find(&:assignment?) || node
          else
            start_line_range(node)
          end
        end

        def argument_case?(node)
          node.case_type? && node.parent && node.parent.send_type?
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
