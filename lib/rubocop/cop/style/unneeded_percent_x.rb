# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of the %x() syntax when `` would do.
      class UnneededPercentX < Cop
        MSG = 'Do not use `%x` unless the command string contains backquotes.'

        def on_xstr(node)
          add_offense(node, :expression) if node.loc.expression.source !~ /`/
        end

        private

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.begin, '`')
            corrector.replace(node.loc.end, '`')
          end
        end
      end
    end
  end
end
