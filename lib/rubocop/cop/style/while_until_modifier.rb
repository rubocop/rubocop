# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for while and until statements that would fit on one line
      # if written as a modifier while/until. The maximum line length is
      # configured in the `Metrics/LineLength` cop.
      class WhileUntilModifier < Cop
        include StatementModifier

        MSG = 'Favor modifier `%<keyword>s` usage when ' \
              'having a single-line body.'.freeze

        def on_while(node)
          check(node)
        end

        def on_until(node)
          check(node)
        end

        private

        def autocorrect(node)
          oneline = "#{node.body.source} #{node.keyword} " \
                    "#{node.condition.source}"

          lambda do |corrector|
            corrector.replace(node.source_range, oneline)
          end
        end

        def check(node)
          return unless node.multiline? && single_line_as_modifier?(node)

          add_offense(node, location: :keyword,
                            message: format(MSG, keyword: node.keyword))
        end
      end
    end
  end
end
