# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks to make sure safe navigation isn't used with `empty?` in
      # a conditional.
      #
      # While the safe navigation operator is generally a good idea, when
      # checking `foo&.empty?` in a conditional, `foo` being `nil` will actually
      # do the opposite of what the author intends.
      #
      # @example
      #   # bad
      #   return if foo&.empty?
      #   return unless foo&.empty?
      #
      #   # good
      #   return if foo && foo.empty?
      #   return unless foo && foo.empty?
      #
      class SafeNavigationWithEmpty < Cop
        MSG = 'Avoid calling `empty?` with the safe navigation operator ' \
          'in conditionals.'.freeze

        def_node_matcher :safe_navigation_empty_in_conditional?, <<-PATTERN
          (if (csend (send ...) :empty?) ...)
        PATTERN

        def on_if(node)
          return unless safe_navigation_empty_in_conditional?(node)

          add_offense(node)
        end
      end
    end
  end
end
