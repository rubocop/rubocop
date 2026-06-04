# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for regexp literals used as `match-current-line`.
      # If a regexp literal is in condition, the regexp matches `$_` implicitly.
      #
      # @example
      #   # bad
      #   if /foo/
      #     do_something
      #   end
      #
      #   # good
      #   if /foo/ =~ $_
      #     do_something
      #   end
      class RegexpAsCondition < Base
        extend AutoCorrector

        MSG = 'Do not use regexp literal as a condition. ' \
              'The regexp literal matches `$_` implicitly.'

        def on_match_current_line(node)
          return if node.ancestors.none?(&:conditional?)
          return if part_of_ignored_node?(node)

          add_offense(node) do |corrector|
            # `!` binds tighter than `=~`, so `!/foo/ =~ $_` would parse as
            # `(!/foo/) =~ $_`. Wrap the match in parentheses to preserve the meaning.
            if node.parent&.send_type? && node.parent.method?(:!)
              corrector.replace(node.parent, "!(#{node.source} =~ $_)")
            else
              corrector.replace(node, "#{node.source} =~ $_")
            end
          end

          ignore_node(node)
        end
      end
    end
  end
end
