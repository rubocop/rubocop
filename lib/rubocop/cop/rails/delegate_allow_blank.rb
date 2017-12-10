# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for delegations that pass :allow_blank as an option
      # instead of :allow_nil. :allow_blank is not a valid option to pass
      # to ActiveSupport#delegate.
      #
      # @example
      #   # bad
      #   delegate :foo, to: :bar, allow_blank: true
      #
      #   # good
      #   delegate :foo, to: :bar, allow_nil: true
      class DelegateAllowBlank < Cop
        MSG = '`allow_blank` is not a valid option, use `allow_nil`.'.freeze

        def_node_matcher :delegate_options, <<-PATTERN
          (send nil? :delegate _ $hash)
        PATTERN

        def_node_matcher :allow_blank_option?, <<-PATTERN
          (pair (sym :allow_blank) true)
        PATTERN

        def on_send(node)
          offending_node = allow_blank_option(node)

          return unless offending_node

          add_offense(offending_node)
        end

        def autocorrect(pair_node)
          lambda do |corrector|
            corrector.replace(pair_node.key.source_range, 'allow_nil')
          end
        end

        private

        def allow_blank_option(node)
          delegate_options(node) do |hash|
            hash.pairs.find { |opt| allow_blank_option?(opt) }
          end
        end
      end
    end
  end
end
