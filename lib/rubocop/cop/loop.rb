# encoding: utf-8

module Rubocop
  module Cop
    class Loop < Cop
      MSG = 'Use Kernel#loop with break rather than begin/end/until(or while).'

      def inspect(file, source, tokens, ast)
        on_node([:while, :until], ast) do |node|
          _cond, body = *node
          type = node.type.to_s

          if body.type == :begin &&
              !node.src.expression.to_source.start_with?(type)
            add_offence(:warning, node.src.keyword.line, MSG)
          end
        end
      end
    end
  end
end
