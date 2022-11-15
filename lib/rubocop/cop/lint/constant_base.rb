# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Avoid meaningless `::` prefix on constant.
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
      class ConstantBase < Base
        extend AutoCorrector

        MSG = 'Avoid meaningless `::` prefix on constant.'

        # @param node [RuboCop::AST::CbaseNode]
        # @return [void]
        def on_cbase(node)
          return unless bad?(node)

          add_offense(node) do |corrector|
            corrector.remove(node)
          end
        end

        private

        # @param node [RuboCop::AST::CbaseNode]
        # @return [Boolean]
        def bad?(node)
          module_nesting_ancestors_of(node).none?
        end

        # @param node [RuboCop::AST::Node]
        # @return [Enumerable<RuboCop::AST::Node>]
        def module_nesting_ancestors_of(node)
          node.each_ancestor(:class, :module).reject do |ancestor|
            ancestor.class_type? && used_in_super_class_part?(node, class_node: ancestor)
          end
        end

        # @param class_node [RuboCop::AST::Node]
        # @param node [RuboCop::AST::CbaseNode]
        # @return [Boolean]
        def used_in_super_class_part?(node, class_node:)
          class_node.parent_class&.each_descendant(:cbase)&.any? do |descendant|
            descendant.eql?(node)
          end
        end
      end
    end
  end
end
