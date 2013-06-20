# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for big numeric literals without _ between groups
      # of digits in them.
      class NumericLiterals < Cop
        MSG = 'Add underscores to large numeric literals to ' +
          'improve their readability.'

        def on_int(node)
          value, = *node

          if value > 10000 &&
              node.loc.expression.source.split('.').grep(/\d{6}/).any?
            add_offence(:convention, node.loc.expression, MSG)
          end
        end

        alias_method :on_float, :on_int
      end
    end
  end
end
