# encoding: utf-8

module Rubocop
  module Cop
    class AndOr < Cop
      MSG = 'Use &&/|| instead of and/or.'

      def inspect(file, source, tokens, ast)
        on_node([:and, :or], ast) do |node|
          if node.src.operator.to_source == node.type.to_s
            add_offence(:convention,
                        node.src.operator.line,
                        MSG)
          end
        end
      end
    end
  end
end
