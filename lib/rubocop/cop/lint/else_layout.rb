# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for odd else block layout - like
      # having an expression on the same line as the else keyword,
      # which is usually a mistake.
      #
      # @example
      #
      #   # bad
      #
      #   if something
      #     ...
      #   else do_this
      #     do_that
      #   end
      #
      # @example
      #
      #   # good
      #
      #   if something
      #     ...
      #   else
      #     do_this
      #     do_that
      #   end
      class ElseLayout < Cop
        MSG = 'Odd `else` layout detected. Did you mean to use `elsif`?'.freeze

        def on_if(node)
          return if node.ternary? || node.elsif?

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

          return unless first_else.source_range.line == node.loc.else.line

          add_offense(first_else, :expression)
        end
      end
    end
  end
end
