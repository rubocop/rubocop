# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of `do` in multi-line `while/until` statements.
      class WhileUntilDo < Cop
        MSG = 'Never use `do` with multi-line `%s`.'
        private_constant :MSG

        def on_while(node)
          handle(node)
        end

        def on_until(node)
          handle(node)
        end

        private

        def handle(node)
          length = node.loc.expression.source.lines.to_a.size
          return unless length > 1
          return unless  node.loc.begin && node.loc.begin.is?('do')

          add_offense(node, :begin, format(MSG, node.type))
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            condition_node, = *node
            end_of_condition_range = condition_node.loc.expression.end
            do_range = node.loc.begin
            whitespaces_and_do_range = end_of_condition_range.join(do_range)
            corrector.remove(whitespaces_and_do_range)
          end
        end
      end
    end
  end
end
