# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # { _1.method } should not be used because it won't be picked up by SymbolProc cop.
      #
      # @example
      #
      #   # bad
      #   foo.bar { _1.name }
      #
      #   # bad
      #   foo.bar(1, 2) { _1.xyz }
      #
      #   # good
      #   foo.bar { |it| it.name }
      #
      #   # good
      #   foo.bar { _1 + _2 }
      #
      class UseNamedBlockArgumentForSimpleMethodCalls < Base
        extend AutoCorrector

        MSG = 'Use `{ |it| it.method }` instead of `{ _1.method }`.'

        def_node_matcher :bad_method?, <<~PATTERN
          (numblock
            (...) 1
            $(send (lvar :_1) $_)
          )
        PATTERN

        def on_numblock(node)
          bad_method?(node) do |block, symbol|
            add_offense(node) do |corrector|
              autocorrect(corrector, block, symbol)
            end
          end
        end

        private

        def autocorrect(corrector, block, symbol)
          corrector.replace(block, "|it| it.#{symbol}")
        end
      end
    end
  end
end
