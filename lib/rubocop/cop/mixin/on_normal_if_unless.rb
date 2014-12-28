# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for cops checking if and unless expressions.
    module OnNormalIfUnless
      include IfNode

      def on_if(node)
        invoke_hook_for_normal_if_unless(node)
      end

      def invoke_hook_for_normal_if_unless(node)
        # We won't check modifier or ternary conditionals.
        return if modifier_if?(node) || ternary_op?(node)
        on_normal_if_unless(node)
      end
    end
  end
end
