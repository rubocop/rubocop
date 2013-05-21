# encoding: utf-8

module Rubocop
  module Cop
    class AvoidClassVars < Cop
      MSG = 'Replace class var %s with a class instance var.'

      def inspect(file, source, tokens, ast)
        process(ast)
      end

      def on_cvdecl(node)
        class_var = node.src.name.to_source

        add_offence(:convention,
                    node.src.name.line,
                    sprintf(MSG, class_var))

        super
      end
    end
  end
end
