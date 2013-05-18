# encoding: utf-8

module Rubocop
  module Cop
    class AvoidClassVars < Cop
      MSG = 'Replace class var %s with a class instance var.'

      def inspect(file, source, tokens, ast)
        on_node(:cvdecl, ast) do |node|
          class_var = node.src.name.to_source

          add_offence(
            :convention,
            node.src.name.line,
            sprintf(MSG, class_var)
          )
        end
      end
    end
  end
end
