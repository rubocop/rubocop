# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for usage of the %x() syntax when `` would do.
      class UnneededPercentX < Cop
        MSG = 'Do not use `%x` unless the command string contains backquotes.'
        private_constant :MSG

        def on_xstr(node)
          return unless node.loc.expression.source !~ /`/
          add_offense(node, :expression, MSG)
        end

        private

        def autocorrect(node)
          string, = *node
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.expression,
                              "`#{string.loc.expression.source}`")
          end
        end
      end
    end
  end
end
