# encoding: utf-8

module Rubocop
  module Cop
    module Util
      module_function

      def strip_quotes(str)
        if str[0] == '"' || str[0] == "'"
          str[0] = ''
          str[-1] = ''
        else
          # we're dealing with %q or %Q
          str[0, 3] = ''
          str[-1] = ''
        end

        str
      end

      def block_length(block_node)
        block_node.src.end.line - block_node.src.begin.line
      end
    end
  end
end
