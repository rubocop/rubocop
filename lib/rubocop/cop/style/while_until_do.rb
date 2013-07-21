# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of `do` in multi-line `while/until` statements.
      class WhileUntilDo < Cop
        def on_while(node)
          handle(node)
        end

        def on_until(node)
          handle(node)
        end

        def handle(node)
          length = node.loc.expression.source.lines.to_a.size

          if length > 1
            if node.loc.begin && node.loc.begin.is?('do')
              add_offence(:convention,
                          node.loc.begin,
                          error_message(node.type),
                          node: node)
            end
          end
        end

        private

        def error_message(node_type)
          format('Never use `do` with multi-line `%s`.', node_type)
        end
      end
    end
  end
end
