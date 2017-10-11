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
      class RegexpInCondition < Cop
        MSG = 'Do not use regexp literal in condition.' \
              ' The regexp literal matches `$_` implicitly.'.freeze

        def on_match_current_line(node)
          add_offense(node)
        end
      end
    end
  end
end
