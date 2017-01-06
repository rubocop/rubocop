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
      class GuardClause < Cop
        include MinBodyLength
        include OnMethodDef

        MSG = 'Use a guard clause instead of wrapping the code inside a ' \
              'conditional expression.'.freeze

        def on_method_def(_node, _method_name, _args, body)
          return unless body

          if body.if_type?
            check_ending_if(body)
          elsif body.begin_type? && body.children.last.if_type?
            check_ending_if(body.children.last)
          end
        end

        def on_if(node)
          return if accepted_form?(node) || !contains_guard_clause?(node)

          add_offense(node, :keyword)
        end

        private

        def check_ending_if(node)
          return if accepted_form?(node, true) || !min_body_length?(node)

          add_offense(node, :keyword)
        end

        def accepted_form?(node, ending = false)
          accepted_if?(node, ending) || node.condition.multiline?
        end

        def accepted_if?(node, ending)
          return true if node.modifier_form? || node.ternary?

          if ending
            node.else?
          else
            !node.else? || node.elsif?
          end
        end

        def contains_guard_clause?(node)
          node.if_branch && node.if_branch.guard_clause? ||
            node.else_branch && node.else_branch.guard_clause?
        end
      end
    end
  end
end
