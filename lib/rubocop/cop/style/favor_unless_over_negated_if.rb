# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of if with a negated condition. Only ifs
      # without else are considered.
      class FavorUnlessOverNegatedIf < Cop
        include NegativeConditional

        def on_if(node)
          return unless node.loc.respond_to?(:keyword)
          return if node.loc.keyword.is?('elsif')

          check(node)
        end

        def error_message
          'Favor unless (or control flow or) over if for negative conditions.'
        end
      end
    end
  end
end
