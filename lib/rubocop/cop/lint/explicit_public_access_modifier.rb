# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for the presence of explicit public access modifier.
      #
      # @example
      #
      #   # bad
      #   class Test
      #     public
      #
      #     def test; end
      #   end
      #
      #   class Test
      #     def test; end
      #
      #     public :test
      #   end
      #
      # @example
      #
      #   # good
      #   class Test
      #     def test; end
      #   end
      #
      class ExplicitPublicAccessModifier < Base
        MSG = 'Avoid `public` access modifier.'

        RESTRICT_ON_SEND = %i[public].freeze

        # @!method on_public?(node)
        def_node_matcher :on_public?, <<~PATTERN
          (send nil? :public ...)
        PATTERN

        def on_send(node)
          add_offense(node) if on_public_with_args?(node) || on_public_without_args?(node)
        end

        private

        def on_public_with_args?(node)
          (parent = node.parent) && (parent.module_type? || parent.class_type?)
        end

        def on_public_without_args?(node)
          node.parent&.begin_type? &&
            (grandparent = node.parent&.parent) &&
            (grandparent.module_type? || grandparent.class_type?)
        end
      end
    end
  end
end
