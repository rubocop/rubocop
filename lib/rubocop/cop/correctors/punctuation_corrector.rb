# frozen_string_literal: true

module RuboCop
  module Cop
    # This auto-corrects punctuation
    class PunctuationCorrector
      class << self
        def remove_space(space_before)
          ->(corrector) { corrector.remove(space_before) }
        end

        def add_space(token)
          ->(corrector) { corrector.replace(token.pos, token.pos.source + ' ') }
        end
      end
    end
  end
end
