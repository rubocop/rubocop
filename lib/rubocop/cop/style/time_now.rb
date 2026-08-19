# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `Time.new` without arguments, which is an implicit way
      # to retrieve the current system time. Prefer the more explicit `Time.now`.
      #
      # @example
      #   # bad
      #   Time.new
      #
      #   # good
      #   Time.now
      #
      #   # good - `Time.new` with arguments constructs a specific time
      #   Time.new(2026, 8, 19)
      #
      class TimeNow < Base
        extend AutoCorrector

        MSG = 'Prefer `Time.now` over `Time.new` to retrieve the current time.'
        RESTRICT_ON_SEND = %i[new].freeze

        # @!method time_new?(node)
        def_node_matcher :time_new?, <<~PATTERN
          (call (const {nil? cbase} :Time) :new)
        PATTERN

        def on_send(node)
          return unless time_new?(node)

          add_offense(node) do |corrector|
            corrector.replace(node.loc.selector.join(node.source_range.end), 'now')
          end
        end
        alias on_csend on_send
      end
    end
  end
end
