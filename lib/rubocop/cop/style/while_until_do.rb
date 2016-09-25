# frozen_string_literal: true

module RuboCop
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
          length = node.source.lines.to_a.size
          return unless length > 1
          return unless node.loc.begin && node.loc.begin.is?('do')

          add_offense(node, :begin, error_message(node.type))
        end

        private

        def error_message(node_type)
          format('Do not use `do` with multi-line `%s`.', node_type)
        end

        def autocorrect(node)
          condition_node, = *node
          end_of_condition_range = condition_node.source_range.end
          do_range = node.loc.begin
          whitespaces_and_do_range = end_of_condition_range.join(do_range)
          ->(corrector) { corrector.remove(whitespaces_and_do_range) }
        end
      end
    end
  end
end
