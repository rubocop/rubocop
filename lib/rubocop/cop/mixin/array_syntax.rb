# encoding: utf-8

module Rubocop
  module Cop
    # Common code for ordinary arrays with [] that can be written with %
    # syntax.
    module ArraySyntax
      def array_of?(element_type, node)
        return false unless square_brackets?(node)

        array_elems = node.children

        # no need to check empty arrays
        return false unless array_elems && array_elems.size > 1

        array_elems.all? { |e| e.type == element_type }
      end

      def square_brackets?(node)
        node.loc.begin && node.loc.begin.is?('[')
      end
    end
  end
end
