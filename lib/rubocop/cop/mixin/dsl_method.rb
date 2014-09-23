# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for identifying invocation of DSL methods.
    module DSLMethod
      def dsl_methods
        cop_config['DSLMethods']
      end

      def dsl_method_name(node)
        block_send, _block_args, _block_body = *node
        _breceiver, bmethod_name, _bargs = *block_send

        bmethod_name
      end

      def dsl_method?(node)
        return false unless node.type == :block

        block_send, _block_args, _block_body = *node
        breceiver, bmethod_name, _bargs = *block_send

        breceiver.nil? && dsl_methods.include?(bmethod_name.to_s)
      end
    end
  end
end
