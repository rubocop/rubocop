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
        include IfNode
        include MinBodyLength
        include OnMethodDef

        MSG = 'Use a guard clause instead of wrapping the code inside a ' \
              'conditional expression.'.freeze

        def on_method_def(_node, _method_name, _args, body)
          return unless body

          if body.if_type?
            check_ending_if(body)
          elsif body.begin_type?
            check_ending_if(body.children.last)
          end
        end

        def on_if(node)
          return if accepted_form?(node) || !contains_guard_clause?(node)

          add_offense(node, :keyword, MSG)
        end

        private

        def check_ending_if(node)
          return if !node.if_type? ||
                    accepted_form?(node, true) ||
                    !min_body_length?(node)

          add_offense(node, :keyword, MSG)
        end

        def accepted_form?(node, ending = false)
          condition, = *node

          ignored_node?(node, ending) || condition.multiline?
        end

        def ignored_node?(node, ending)
          return true if modifier_if?(node) || ternary?(node)

          if ending
            if_else?(node)
          else
            !if_else?(node) || elsif?(node)
          end
        end

        def contains_guard_clause?(node)
          _, body, else_body = *node

          guard_clause?(body) || guard_clause?(else_body)
        end
      end
    end
  end
end
