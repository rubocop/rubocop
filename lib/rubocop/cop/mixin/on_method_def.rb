# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking instance methods and singleton methods.
    module OnMethodDef
      def on_def(node)
        method_name, args, body = *node
        on_method_def(node, method_name, args, body)
      end

      def on_defs(node)
        _scope, method_name, args, body = *node
        on_method_def(node, method_name, args, body)
      end

      # This method provides scope agnostic method node destructuring by moving
      # the scope to the end where it can easily be ignored.
      def method_def_node_parts(node)
        if node.def_type?
          method_name, args, body = *node
        elsif node.defs_type?
          scope, method_name, args, body = *node
        else
          return []
        end

        [method_name, args, body, scope]
      end

      private

      # Returns true for constructs such as
      # private def my_method
      # which are allowed in Ruby 2.1 and later.
      def modifier_and_def_on_same_line?(send_node)
        send_node.receiver.nil? &&
          send_node.method_name != :def &&
          send_node.method_args.size == 1 &&
          [:def, :defs].include?(send_node.method_args.first.type)
      end
    end
  end
end
