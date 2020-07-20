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
          ->(corrector) { corrector.replace(token.pos, "#{token.pos.source} ") }
        end

        def swap_comma(range)
          return unless range

          lambda do |corrector|
            case range.source
            when ',' then corrector.remove(range)
            else          corrector.insert_after(range, ',')
            end
          end
        end
      end
    end
  end
end
