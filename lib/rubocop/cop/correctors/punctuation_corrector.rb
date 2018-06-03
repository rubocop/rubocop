# frozen_string_literal: true

module RuboCop
  module Cop
    # This auto-corrects punctuation
    class PunctuationCorrector
      class << self
        include RangeHelp

        attr_reader :processed_source

        def remove_space(space_before)
          ->(corrector) { corrector.remove(space_before) }
        end

        def add_space(token)
          ->(corrector) { corrector.replace(token.pos, token.pos.source + ' ') }
        end

        def swap_comma(range, processed_source)
          return unless range
          @processed_source = processed_source

          lambda do |corrector|
            case range.source
            when ',' then corrector.remove(range)
            else
              verify_correction_still_needed(range)
              corrector.insert_after(range, ',')
            end
          end
        end

        private

        def verify_correction_still_needed(range)
          # This should check whether the correction is still needed.
          # However, the processed_source represents the original code and not
          # the newly modified code.
        end
      end
    end
  end
end
