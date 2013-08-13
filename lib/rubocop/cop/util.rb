# encoding: utf-8

module Rubocop
  module Cop
    # This module contains a collection of useful utility methods.
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
        block_node.loc.end.line - block_node.loc.begin.line
      end

      def const_name(node)
        return nil if node.nil? || node.type != :const

        const_names = []
        const_node = node

        loop do
          namespace_node, name = *const_node
          const_names << name
          break unless namespace_node
          break if namespace_node.type == :cbase
          const_node = namespace_node
        end

        const_names.reverse.join('::')
      end
    end
  end
end
