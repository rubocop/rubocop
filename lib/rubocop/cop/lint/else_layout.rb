# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for odd `else` block layout - like
      # having an expression on the same line as the `else` keyword,
      # which is usually a mistake.
      #
      # Its auto-correction tweaks layout to keep the syntax. So, this auto-correction
      # is compatible correction for bad case syntax, but if your code makes a mistake
      # with `elsif` and `else`, you will have to correct it manually.
      #
      # @example
      #
      #   # bad
      #
      #   if something
      #     # ...
      #   else do_this
      #     do_that
      #   end
      #
      # @example
      #
      #   # good
      #
      #   # This code is compatible with the bad case. It will be auto-corrected like this.
      #   if something
      #     # ...
      #   else
      #     do_this
      #     do_that
      #   end
      #
      #   # This code is incompatible with the bad case.
      #   # If `do_this` is a condition, `elsif` should be used instead of `else`.
      #   if something
      #     # ...
      #   elsif do_this
      #     do_that
      #   end
      class ElseLayout < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Odd `else` layout detected. Did you mean to use `elsif`?'

        def on_if(node)
          return if node.ternary?

          check(node)
        end

        private

        def check(node)
          return unless node.else_branch

          if node.else? && node.loc.else.is?('else')
            check_else(node)
          elsif node.if?
            check(node.else_branch)
          end
        end

        def check_else(node)
          else_branch = node.else_branch

          return unless else_branch.begin_type?

          first_else = else_branch.children.first

          return unless first_else
          return unless first_else.source_range.line == node.loc.else.line

          add_offense(first_else) do |corrector|
            autocorrect(corrector, node, first_else)
          end
        end

        def autocorrect(corrector, node, first_else)
          corrector.insert_after(node.loc.else, "\n")

          blank_range = range_between(node.loc.else.end_pos, first_else.loc.expression.begin_pos)
          indentation = indent(node.else_branch.children[1])
          corrector.replace(blank_range, indentation)
        end
      end
    end
  end
end
