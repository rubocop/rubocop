# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for identifying invocation of DSL methods. Without
    # specific knowledge of the DSL being used, the best we can do is detect a
    # method called directly inside a class/module, and treat the body as a
    # method when running cops.
    #
    # @example
    #
    # module Test
    #   some_dsl('/path/to/something') do
    #     # ...
    #   end
    # end
    module OnDSLMethod
      def on_class(node)
        _cname, _cparent, cbody = *node
        traverse(cbody)
      end

      def on_module(node)
        _mname, mbody = *node
        traverse(mbody)
      end

      def dsl_method_name(node)
        block_send, _block_args, _block_body = *node
        _breceiver, bmethod_name, _bargs = *block_send

        bmethod_name
      end

      private

      def traverse(body)
        children = body.type == :begin ? body.children : [body]
        children.each do |child|
          on_dsl_method(child) if dsl_method?(child)
        end
      end

      def dsl_method?(node)
        return false unless check_dsl_methods? && node.type == :block

        block_send, _block_args, _block_body = *node
        breceiver, _bmethod_name, _bargs = *block_send

        breceiver.nil?
      end

      def check_dsl_methods?
        cop_config['DSLMethods']
      end
    end
  end
end
