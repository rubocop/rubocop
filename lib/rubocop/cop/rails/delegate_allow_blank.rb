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

        def_node_matcher :delegate, <<-PATTERN
          (send _ :delegate _ $hash)
        PATTERN

        def_node_matcher :delegate_options, <<-PATTERN
          (hash $...)
        PATTERN

        def_node_matcher :allow_blank?, <<-PATTERN
          (pair $(sym :allow_blank) true)
        PATTERN

        def on_send(node)
          offending_node = allow_blank_option(node)
          return unless offending_node

          allow_blank = offending_node.children.first
          add_offense(node, allow_blank.source_range, MSG)
        end

        def autocorrect(node)
          offending_node = allow_blank_option(node)
          return unless offending_node

          allow_blank = offending_node.children.first
          lambda do |corrector|
            corrector.replace(allow_blank.source_range, 'allow_nil')
          end
        end

        private

        def allow_blank_option(node)
          options_hash = delegate(node)
          return unless options_hash
          options = delegate_options(options_hash)
          return unless options

          options.detect { |opt| allow_blank?(opt) }
        end
      end
    end
  end
end
