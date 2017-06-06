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
        MSG = 'Put a space before an end-of-line comment.'.freeze

        def investigate(processed_source)
          processed_source.tokens.each_cons(2) do |t1, t2|
            next unless t2.type == :tCOMMENT
            next unless t1.pos.line == t2.pos.line
            add_offense(t2.pos, t2.pos) if t1.pos.end == t2.pos.begin
          end
        end

        private

        def autocorrect(range)
          ->(corrector) { corrector.insert_before(range, ' ') }
        end
      end
    end
  end
end
