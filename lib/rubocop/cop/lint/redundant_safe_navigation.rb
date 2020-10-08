# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for redundant safe navigation calls.
      # It is marked as unsafe, because it can produce code that returns
      # non `nil` while `nil` result is expected on `nil` receiver.
      #
      # @example
      #   # bad
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
