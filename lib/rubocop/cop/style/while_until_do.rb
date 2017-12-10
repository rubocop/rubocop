# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of `do` in multi-line `while/until` statements.
      #
      # @example
      #
      #   # bad
      #   while x.any? do
      #     do_something(x.pop)
      #   end
      #
      #   # good
      #   while x.any?
      #     do_something(x.pop)
      #   end
      #
      # @example
      #
      #   # bad
      #   until x.empty? do
      #     do_something(x.pop)
      #   end
      #
      #   # good
      #   until x.empty?
      #     do_something(x.pop)
      #   end
      class WhileUntilDo < Cop
        MSG = 'Do not use `do` with multi-line `%<keyword>s`.'.freeze

        def on_while(node)
          handle(node)
        end

        def on_until(node)
          handle(node)
        end

        def handle(node)
          return unless node.multiline? && node.do?

          add_offense(node, location: :begin,
                            message: format(MSG, keyword: node.keyword))
        end

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
