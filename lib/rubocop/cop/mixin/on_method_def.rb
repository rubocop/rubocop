# encoding: utf-8

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

      private

      # Returns true for constructs such as
      # private def my_method
      # which are allowed in Ruby 2.1 and later.
      def modifier_and_def_on_same_line?(receiver, method_name, args)
        !receiver &&
          method_name != :def &&
          args.size == 1 &&
          [:def, :defs].include?(args.first.type)
      end
    end
  end
end
