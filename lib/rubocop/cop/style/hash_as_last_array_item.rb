# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for presence or absence of braces around hash literal as a last
      # array item depending on configuration.
      #
      # @example EnforcedStyle: braces (default)
      #   # bad
      #   [1, 2, one: 1, two: 2]
      #
      #   # good
      #   [1, 2, { one: 1, two: 2 }]
      #
      # @example EnforcedStyle: no_braces
      #   # bad
      #   [1, 2, { one: 1, two: 2 }]
      #
      #   # good
      #   [1, 2, one: 1, two: 2]
      #
      class HashAsLastArrayItem < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        def on_hash(node)
          return unless last_array_item?(node)

          if braces_style?
            check_braces(node)
          else
            check_no_braces(node)
          end
        end

        private

        def last_array_item?(node)
          parent = node.parent
          return false unless parent

          parent.array_type? && parent.children.last.equal?(node)
        end

        def check_braces(node)
          return if node.braces?

          add_offense(node, message: 'Wrap hash in `{` and `}`.') do |corrector|
            corrector.wrap(node, '{', '}')
          end
        end

        def check_no_braces(node)
          return unless node.braces?

          add_offense(node, message: 'Omit the braces around the hash.') do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end

        def braces_style?
          style == :braces
        end
      end
    end
  end
end
