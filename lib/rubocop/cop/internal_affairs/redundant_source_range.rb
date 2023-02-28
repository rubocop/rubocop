# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for redundant `source_range`.
      #
      # @example
      #
      #   # bad
      #   node.source_range.source
      #
      #   # good
      #   node.source
      #
      class RedundantSourceRange < Base
        extend AutoCorrector

        MSG = 'Remove the redundant `source_range`.'
        RESTRICT_ON_SEND = %i[source].freeze

        # @!method redundant_source_range(node)
        def_node_matcher :redundant_source_range, <<~PATTERN
          (send $(send _ :source_range) :source)
        PATTERN

        def on_send(node)
          return unless (source_range = redundant_source_range(node))

          selector = source_range.loc.selector

          add_offense(selector) do |corrector|
            corrector.remove(source_range.loc.dot.join(selector))
          end
        end
      end
    end
  end
end
