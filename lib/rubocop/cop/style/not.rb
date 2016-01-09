# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses if the keyword *not* instead of !.
      class Not < Cop
        include AutocorrectUnlessChangingAST

        MSG = 'Use `!` instead of `not`.'.freeze

        def on_send(node)
          return unless node.keyword_not?

          add_offense(node, :selector)
        end

        private

        def correction(node)
          new_source = node.source.sub(/not\s+/, '!')
          ->(corrector) { corrector.replace(node.source_range, new_source) }
        end
      end
    end
  end
end
