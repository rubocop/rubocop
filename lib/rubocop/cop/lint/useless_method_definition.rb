# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for useless method definitions, specifically: empty constructors
      # and methods just delegating to `super`.
      #
      # This cop is marked as unsafe as it can trigger false positives for cases when
      # an empty constructor just overrides the parent constructor, which is bad anyway.
      #
      # @example
      #   # bad
      #   def initialize
      #   end
      #
      #   def method
      #     super
      #   end
      #
      #   # good
      #   def initialize
      #     initialize_internals
      #   end
      #
      #   def method
      #     super
      #     do_something_else
      #   end
      #
      # @example AllowComments: true (default)
      #   # good
      #   def initialize
      #     # Comment.
      #   end
      #
      # @example AllowComments: false
      #   # bad
      #   def initialize
      #     # Comment.
      #   end
      #
      class UselessMethodDefinition < Base
        extend AutoCorrector

        MSG = 'Useless method definition detected.'

        def on_def(node)
          return unless (constructor?(node) && empty_constructor?(node)) ||
                        delegating?(node.body, node)

          add_offense(node) { |corrector| corrector.remove(node) }
        end
        alias on_defs on_def

        private

        def empty_constructor?(node)
          return false if node.body
          return false if cop_config['AllowComments'] && comment_lines?(node)

          true
        end

        def constructor?(node)
          node.def_type? && node.method?(:initialize)
        end

        def delegating?(node, def_node)
          return false unless node&.super_type? || node&.zsuper_type?

          !node.arguments? || node.arguments.map(&:source) == def_node.arguments.map(&:source)
        end
      end
    end
  end
end
