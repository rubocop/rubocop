# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of `do` in multi-line `while/until` statements.
      class WhileUntilDo < Cop
        MSG = 'Do not use `do` with multi-line `%s`.'.freeze

        def on_while(node)
          handle(node)
        end

        def on_until(node)
          handle(node)
        end

        def handle(node)
          return unless node.multiline? && node.do?

          add_offense(node, :begin, format(MSG, node.keyword))
        end

        private

        def autocorrect(node)
          do_range = node.condition.source_range.end.join(node.loc.begin)

          lambda do |corrector|
            corrector.remove(do_range)
          end
        end
      end
    end
  end
end
