# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLiteral < Cop
      ARR_MSG = 'Use array literal [] instead of Array.new.'
      HASH_MSG = 'Use hash literal {} instead of Hash.new.'
      STR_MSG = "Use string literal '' instead of String.new."

      # Empty array node
      #
      # (send
      #   (const nil :Array) :new)
      ARRAY_NODE = s(:send, s(:const, nil, :Array), :new)

      # Empty hash node
      #
      # (send
      #   (const nil :Hash) :new)
      HASH_NODE = s(:send, s(:const, nil, :Hash), :new)

      # Empty string node
      #
      # (send
      #   (const nil :String) :new)
      STR_NODE = s(:send, s(:const, nil, :String), :new)

      def inspect(file, source, tokens, ast)
        on_node(:send, ast, :block) do |node|
          if node == ARRAY_NODE
            add_offence(:convention,
                        node.loc.line,
                        ARR_MSG)
          elsif node == HASH_NODE
            add_offence(:convention,
                        node.loc.line,
                        HASH_MSG)
          elsif node == STR_NODE
            add_offence(:convention,
                        node.loc.line,
                        STR_MSG)
          end
        end
      end
    end
  end
end
