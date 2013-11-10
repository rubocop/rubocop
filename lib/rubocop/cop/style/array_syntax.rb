# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Common code for ordinary arrays with [] that can be written with %
      # syntax.
      module ArraySyntax
        def array_of?(element_type, node)
          return false unless node.loc.begin && node.loc.begin.is?('[')

          array_elems = node.children

          # no need to check empty arrays
          return false unless array_elems && array_elems.size > 1

          array_elems.all? { |e| e.type == element_type }
        end
      end
    end
  end
end
