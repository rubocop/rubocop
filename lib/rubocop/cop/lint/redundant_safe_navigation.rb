# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for redundant safe navigation calls.
      #
      # In the example below, the safe navigation operator (`&.`) is unnecessary
      # because `NilClass` has methods like `respond_to?` and `dup`.
      #
      # This cop is marked as unsafe, because auto-correction can change the
      # return type of the expression. An offending expression that previously
      # could return `nil` will be auto-corrected to never return `nil`.
      #
      # @example
      #   # bad, because nil has these methods
      #   attrs&.respond_to?(:[])
      #   foo&.dup&.inspect
      #
      #   # good
      #   attrs.respond_to?(:[])
      #   foo.dup.inspect
      #
      class RedundantSafeNavigation < Base
        include IgnoredMethods
        include RangeHelp
        extend AutoCorrector

        MSG = 'Redundant safe navigation detected.'

        NIL_METHODS = nil.methods.to_set.freeze

        def on_csend(node)
          return unless check_method?(node.method_name)

          range = range_between(node.loc.dot.begin_pos, node.source_range.end_pos)
          add_offense(range) do |corrector|
            corrector.replace(node.loc.dot, '.')
          end
        end

        private

        def check_method?(method_name)
          NIL_METHODS.include?(method_name) && !ignored_method?(method_name)
        end
      end
    end
  end
end
