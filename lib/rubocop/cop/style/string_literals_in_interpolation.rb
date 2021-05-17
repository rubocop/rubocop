# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that quotes inside the string interpolation
      # match the configured preference.
      #
      # @example EnforcedStyle: single_quotes (default)
      #   # bad
      #   result = "Tests #{success ? "PASS" : "FAIL"}"
      #
      #   # good
      #   result = "Tests #{success ? 'PASS' : 'FAIL'}"
      #
      # @example EnforcedStyle: double_quotes
      #   # bad
      #   result = "Tests #{success ? 'PASS' : 'FAIL'}"
      #
      #   # good
      #   result = "Tests #{success ? "PASS" : "FAIL"}"
      class StringLiteralsInInterpolation < Base
        include ConfigurableEnforcedStyle
        include StringLiteralsHelp
        include StringHelp
        extend AutoCorrector

        def autocorrect(corrector, node)
          StringLiteralCorrector.correct(corrector, node, style)
        end

        private

        def message(_node)
          # single_quotes -> single-quoted
          kind = style.to_s.sub(/_(.*)s/, '-\1d')

          "Prefer #{kind} strings inside interpolations."
        end

        def offense?(node)
          # If it's not a string within an interpolation, then it's not an
          # offense for this cop.
          return false unless inside_interpolation?(node)

          wrong_quotes?(node)
        end
      end
    end
  end
end
