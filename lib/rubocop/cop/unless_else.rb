# encoding: utf-8

module Rubocop
  module Cop
    class UnlessElse < Cop
      MSG = 'Never use unless with else. Rewrite these with the ' +
        'positive case first.'

      def inspect(file, source, tokens, ast)
        on_node(:if, ast) do |s|
          src = s.loc

          # discard ternary ops and modifier if/unless nodes
          next unless src.respond_to?(:keyword) && src.respond_to?(:else)

          if src.keyword.source == 'unless' && src.else
            add_offence(:convention, src.line,
                        MSG)
          end
        end
      end
    end
  end
end
