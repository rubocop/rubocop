# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiteralsInInterpolation < Cop
        include ConfigurableEnforcedStyle
        include StringLiteralsHelp

        private

        def message(*)
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
