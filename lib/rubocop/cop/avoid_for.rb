# encoding: utf-8

module Rubocop
  module Cop
    class AvoidFor < Cop
      MSG = 'Prefer *each* over *for*.'

      def inspect(file, source, tokens, ast)
        process(ast)
      end

      def on_for(node)
        add_offence(:convention,
                    node.src.keyword.line,
                    MSG)
      end
    end
  end
end
