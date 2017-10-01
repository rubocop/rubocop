# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for comparison of something with nil using ==.
      #
      # @example
      #
      #  # bad
      #  if x == nil
      #
      #  # good
      #  if x.nil?
      class NilComparison < Cop
        MSG = 'Prefer the use of the `nil?` predicate.'.freeze

        def_node_matcher :nil_comparison?, '(send _ {:== :===} nil)'

        def on_send(node)
          nil_comparison?(node) do
            add_offense(node, :selector)
          end
        end

        private

        def autocorrect(node)
          new_code = node.source.sub(/\s*={2,3}\s*nil/, '.nil?')
          ->(corrector) { corrector.replace(node.source_range, new_code) }
        end
      end
    end
  end
end
