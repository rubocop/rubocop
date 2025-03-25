# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Consistently use `shared_examples` over `shared_examples_for` when
      # defining shared examples in tests.
      #
      # NOTE: Although `shared_context` is also an alias of `shared_examples`, this
      # cop does not consider it as it has a different English meaning.
      #
      # @example
      #
      #   # bad
      #   shared_examples_for '...' do
      #   end
      #
      #   # good
      #   shared_examples '...' do
      #   end
      #
      class SharedExamples < Base
        extend AutoCorrector

        MSG = 'Use `shared_examples` instead of `shared_examples_for`.'

        RESTRICT_ON_SEND = %i[shared_examples_for].to_set.freeze

        # @!method rspec_const?(node)
        def_node_matcher :rspec_const?, <<~PATTERN
          (const {nil? cbase} :RSpec)
        PATTERN

        def on_send(node)
          return unless offense?(node)

          selector = node.loc.selector

          add_offense(selector) do |corrector|
            corrector.replace(selector, 'shared_examples')
          end
        end

        private

        def offense?(node)
          node.receiver.nil? || rspec_const?(node.receiver)
        end
      end
    end
  end
end
