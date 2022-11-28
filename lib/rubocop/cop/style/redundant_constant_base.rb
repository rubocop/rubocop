# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Avoid redundant `::` prefix on constant.
      #
      # How Ruby searches constant is a bit complicated, and it can often be difficult to
      # understand from the code whether the `::` is intended or not. Where `Module.nesting`
      # is empty, there is no need to prepend `::`, so it would be nice to consistently
      # avoid such meaningless `::` prefix to avoid confusion.
      #
      # @example
      #   # bad
      #   ::Const
      #
      #   # good
      #   Const
      #
      #   # bad
      #   class << self
      #     ::Const
      #   end
      #
      #   # good
      #   class << self
      #     Const
      #   end
      #
      #   # good
      #   class A
      #     ::Const
      #   end
      #
      #   # good
      #   module A
      #     ::Const
      #   end
      class RedundantConstantBase < Base
        extend AutoCorrector

        MSG = 'Remove redundant `::`.'

        def on_cbase(node)
          return unless bad?(node)

          add_offense(node) do |corrector|
            corrector.remove(node)
          end
        end

        private

        def bad?(node)
          module_nesting_ancestors_of(node).none?
        end

        def module_nesting_ancestors_of(node)
          node.each_ancestor(:class, :module).reject do |ancestor|
            ancestor.class_type? && used_in_super_class_part?(node, class_node: ancestor)
          end
        end

        def used_in_super_class_part?(node, class_node:)
          class_node.parent_class&.each_descendant(:cbase)&.any? do |descendant|
            descendant.equal?(node)
          end
        end
      end
    end
  end
end
