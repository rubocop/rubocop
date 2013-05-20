# encoding: utf-8

module Rubocop
  module Cop
    class Not < Cop
      MSG = 'Use ! instead of not.'

      def inspect(file, source, tokens, ast)
        on_node(:send, ast) do |node|
          _receiver, method_name, *args = *node

          # not does not take any arguments
          next unless args.empty?

          if method_name == :! && node.src.selector.to_source == 'not'
            add_offence(:convention, node.src.line, MSG)
          end
        end
      end
    end
  end
end
