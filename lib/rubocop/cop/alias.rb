# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      MSG = 'Use alias_method instead of alias.'

      def inspect(file, source, tokens, ast)
        process(ast)
      end

      def on_alias(node)
        add_offence(:convention,
                    node.src.keyword.line,
                    MSG)

        super
      end
    end
  end
end
