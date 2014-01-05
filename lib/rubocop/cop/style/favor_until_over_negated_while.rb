# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of while with a negated condition.
      class FavorUntilOverNegatedWhile < Cop
        include NegativeConditional

        def on_while(node)
          check(node)
        end

        def error_message
          'Favor until over while for negative conditions.'
        end
      end
    end
  end
end
