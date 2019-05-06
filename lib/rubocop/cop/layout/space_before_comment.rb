# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for missing space between a token and a comment on the
      # same line.
      #
      # @example
      #   # bad
      #   1 + 1# this operation does ...
      #
      #   # good
      #   1 + 1 # this operation does ...
      class SpaceBeforeComment < Cop
        MSG = 'Put a space before an end-of-line comment.'

        def investigate(processed_source)
          processed_source.tokens.each_cons(2) do |token1, token2|
            next unless token2.comment?
            next unless token1.line == token2.line

            if token1.pos.end == token2.pos.begin
              add_offense(token2.pos, location: token2.pos)
            end
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.insert_before(range, ' ') }
        end
      end
    end
  end
end
