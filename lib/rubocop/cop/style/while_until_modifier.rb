# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for while and until statements that would fit on one line
      # if written as a modifier while/until. The maximum line length is
      # configured in the `Layout/LineLength` cop.
      #
      # @example
      #   # bad
      #   while x < 10
      #     x += 1
      #   end
      #
      #   # good
      #   x += 1 while x < 10
      #
      # @example
      #   # bad
      #   until x > 10
      #     x += 1
      #   end
      #
      #   # good
      #   x += 1 until x > 10
      class WhileUntilModifier < Cop
        include StatementModifier

        MSG = 'Favor modifier `%<keyword>s` usage when ' \
              'having a single-line body.'

        def on_while(node)
          check(node)
        end

        def on_until(node)
          check(node)
        end

        def autocorrect(node)
          oneline = "#{node.body.source} #{node.keyword} " \
                    "#{node.condition.source}"

          lambda do |corrector|
            corrector.replace(node, oneline)
          end
        end

        private

        def check(node)
          return unless node.multiline? && single_line_as_modifier?(node)

          add_offense(node, location: :keyword,
                            message: format(MSG, keyword: node.keyword))
        end
      end
    end
  end
end
