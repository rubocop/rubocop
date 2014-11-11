# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for empty else-clauses, possibly including comments and/or an
      # explicit `nil`.
      class EmptyElse < Cop
        include OnNormalIfUnless

        MSG = 'Redundant empty `else`-clause.'

        def on_normal_if_unless(node)
          check(node, if_else_clause(node))
        end

        def on_case(node)
          check(node, case_else_clause(node))
        end

        private

        def check(node, else_clause)
          return unless node.loc.else
          return if else_clause && else_clause.type != :nil

          add_offense(node, :else, MSG)
        end

        def if_else_clause(node)
          keyword = node.loc.keyword
          if keyword.is?('if')
            node.children[2]
          elsif keyword.is?('elsif')
            node.children[2]
          elsif keyword.is?('unless')
            node.children[1]
          end
        end

        def case_else_clause(node)
          node.children.last
        end
      end
    end
  end
end
