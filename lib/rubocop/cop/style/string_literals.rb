# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiterals < Cop
        include ConfigurableEnforcedStyle
        include StringLiteralsHelp

        def on_dstr(node)
          # A dstr node with dstr and str children is a concatenated
          # string. Don't ignore the whole thing.
          return if node.children.find { |child| child.type == :str }

          # Dynamic strings can not use single quotes, and quotes inside
          # interpolation expressions are checked by the
          # StringLiteralsInInterpolation cop, so ignore.
          ignore_node(node)
        end

        private

        def message(*)
          if style == :single_quotes
            "Prefer single-quoted strings when you don't need string " \
            'interpolation or special symbols.'
          else
            'Prefer double-quoted strings unless you need single quotes to ' \
            'avoid extra backslashes for escaping.'
          end
        end

        def offense?(node)
          wrong_quotes?(node, style)
        end
      end
    end
  end
end
