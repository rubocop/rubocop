# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use a guard clause instead of wrapping the code inside a conditional
      # expression
      #
      # @example
      #   # bad
      #   def test
      #     if something
      #       work
      #     end
      #   end
      #
      #   # good
      #   def test
      #     return unless something
      #
      #     work
      #   end
      #
      #   # also good
      #   def test
      #     work if something
      #   end
      #
      #   # bad
      #   if something
      #     raise 'exception'
      #   else
      #     ok
      #   end
      #
      #   # good
      #   raise 'exception' if something
      #   ok
      #
      #   # bad
      #   if something
      #     foo || raise('exception')
      #   else
      #     ok
      #   end
      #
      #   # good
      #   foo || raise('exception') if something
      #   ok
      class GuardClause < Base
        include MinBodyLength
        include StatementModifier

        MSG = 'Use a guard clause (`%<example>s`) instead of wrapping the ' \
              'code inside a conditional expression.'

        def on_def(node)
          body = node.body

          return unless body

          if body.if_type?
            check_ending_if(body)
          elsif body.begin_type?
            final_expression = body.children.last
            check_ending_if(final_expression) if final_expression&.if_type?
          end
        end
        alias on_defs on_def

        def on_if(node)
          return if accepted_form?(node)

          guard_clause_in_if = node.if_branch&.guard_clause?
          guard_clause_in_else = node.else_branch&.guard_clause?
          guard_clause = guard_clause_in_if || guard_clause_in_else
          return unless guard_clause

          kw = if guard_clause_in_if
                 node.loc.keyword.source
               else
                 opposite_keyword(node)
               end

          register_offense(node, guard_clause_source(guard_clause), kw)
        end

        private

        def check_ending_if(node)
          return if accepted_form?(node, ending: true) || !min_body_length?(node)

          register_offense(node, 'return', opposite_keyword(node))
        end

        def opposite_keyword(node)
          node.if? ? 'unless' : 'if'
        end

        def register_offense(node, scope_exiting_keyword, conditional_keyword)
          condition, = node.node_parts
          example = [scope_exiting_keyword, conditional_keyword, condition.source].join(' ')
          if too_long_for_single_line?(node, example)
            example = "#{conditional_keyword} #{condition.source}; #{scope_exiting_keyword}; end"
          end

          add_offense(node.loc.keyword, message: format(MSG, example: example))
        end

        def guard_clause_source(guard_clause)
          parent = guard_clause.parent

          if parent.and_type? || parent.or_type?
            guard_clause.parent.source
          else
            guard_clause.source
          end
        end

        def too_long_for_single_line?(node, example)
          max = max_line_length
          max && node.source_range.column + example.length > max
        end

        def accepted_form?(node, ending: false)
          accepted_if?(node, ending) || node.condition.multiline? || node.parent&.assignment?
        end

        def accepted_if?(node, ending)
          return true if node.modifier_form? || node.ternary?

          if ending
            node.else?
          else
            !node.else? || node.elsif?
          end
        end
      end
    end
  end
end
