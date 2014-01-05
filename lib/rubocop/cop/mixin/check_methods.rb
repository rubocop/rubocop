# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for checking instance methods and singeton methods.
    module CheckMethods
      def on_def(node)
        method_name, args, body = *node
        check(node, method_name, args, body)
      end

      def on_defs(node)
        _scope, method_name, args, body = *node
        check(node, method_name, args, body)
      end
    end
  end
end
