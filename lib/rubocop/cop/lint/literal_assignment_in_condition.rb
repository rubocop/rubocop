# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for literal assignments in the conditions of `if`, `while`, and `until`.
      # It emulates the following Ruby warning:
      #
      # [source,console]
      # ----
      # $ ruby -we 'if x = true; end'
      # -e:1: warning: found `= literal' in conditional, should be ==
      # ----
      #
      # As a lint cop, it cannot be determined if `==` is appropriate as intended,
      # therefore this cop does not provide autocorrection.
      #
      # @example
      #
      #   # bad
      #   if x = 42
      #     do_something
      #   end
      #
      #   # good
      #   if x == 42
      #     do_something
      #   end
      #
      #   # good
      #   if x = y
      #     do_something
      #   end
      #
      class LiteralAssignmentInCondition < Base
        MSG = "Don't use literal assignment `= %<literal>s` in conditional, " \
              'should be `==` or non-literal operand.'

        def on_if(node)
          traverse_node(node.condition) do |asgn_node|
            next unless asgn_node.loc.operator

            rhs = asgn_node.to_a.last
            next unless rhs.respond_to?(:literal?) && rhs.literal?

            range = asgn_node.loc.operator.join(rhs.source_range.end)

            add_offense(range, message: format(MSG, literal: rhs.source))
          end
        end
        alias on_while on_if
        alias on_until on_if

        private

        def traverse_node(node, &block)
          yield node if AST::Node::EQUALS_ASSIGNMENTS.include?(node.type)

          node.each_child_node { |child| traverse_node(child, &block) }
        end
      end
    end
  end
end
