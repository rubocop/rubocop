# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for usage of `Class#subclasses`.
      #
      # This method is unreliable for two main reasons:
      # 1. It doesn't know about classes that have yet to be autoloaded
      # 2. It is non-deterministic with regards to garbage collection of dynamically created classes
      #
      # @safety
      #   This cop is unsafe because it may flag code that intentionally uses this method
      #   with full awareness of its limitations.
      #
      # @example
      #
      #   # bad
      #   MyBaseClass.subclasses.map(&:name)
      #
      class UnreliableSubclasses < Base
        MSG = 'Avoid using `%<method>s` as it is unreliable with autoloading and ' \
              'non-deterministic with garbage collection.'

        RESTRICT_ON_SEND = %i[subclasses].freeze

        # @!method class_introspection_method?(node)
        def_node_matcher :class_introspection_method?, <<~PATTERN
          (send _ :subclasses)
        PATTERN

        def on_send(node)
          return unless class_introspection_method?(node)

          message = format(MSG, method: node.method_name)
          add_offense(node.loc.selector, message: message)
        end
        alias on_csend on_send
      end
    end
  end
end
