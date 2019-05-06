# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for regexp literals used as `match-current-line`.
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
      class RegexpAsCondition < Cop
        MSG = 'Do not use regexp literal as a condition.' \
              ' The regexp literal matches `$_` implicitly.'

        def on_match_current_line(node)
          add_offense(node)
        end
      end
    end
  end
end
