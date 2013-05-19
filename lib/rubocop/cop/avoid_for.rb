# encoding: utf-8

module Rubocop
  module Cop
    class AvoidFor < Cop
      MSG = 'Prefer *each* over *for*.'

      def inspect(file, source, tokens, ast)
        on_node(:for, ast) do |node|
          add_offence(:convention,
                      node.src.keyword.line,
                      MSG)
        end
      end
    end
  end
end
