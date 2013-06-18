# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class UnlessElse < Cop
        MSG = 'Never use unless with else. Rewrite these with the ' +
          'positive case first.'

        def on_if(node)
          loc = node.loc

          # discard ternary ops and modifier if/unless nodes
          return unless loc.respond_to?(:keyword) && loc.respond_to?(:else)

          if loc.keyword.is?('unless') && loc.else
            add_offence(:convention, loc.expression, MSG)
          end

          super
        end
      end
    end
  end
end
