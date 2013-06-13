# encoding: utf-8

module Rubocop
  module Cop
    class BlockNesting < Cop
      NESTING_BLOCKS = [:case, :if, :while, :until, :for, :resbody]

      def inspect(source, tokens, ast, comments)
        max = BlockNesting.config['Max']
        check_nesting_level(ast, max, 0)
      end

      private

      def check_nesting_level(node, max, current_level)
        if NESTING_BLOCKS.include?(node.type)
          current_level += 1
          if current_level == max + 1
            add_offence(:convention, node.location.expression, message(max))
            return
          end
        end
        node.children.each do |child|
          if child.is_a?(Parser::AST::Node)
            check_nesting_level(child, max, current_level)
          end
        end
      end

      def message(max)
        "Avoid more than #{max} levels of block nesting."
      end
    end
  end
end
