# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      MSG = 'Use alias_method instead of alias.'

      def inspect(file, source, tokens, ast)
        on_node(:alias, ast) do |node|
          add_offence(:convention,
                      node.src.keyword.line,
                      MSG)
        end
      end
    end
  end
end
