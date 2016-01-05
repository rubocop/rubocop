# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiterals < Cop
        include ConfigurableEnforcedStyle
        include StringLiteralsHelp

        private

        def message(*)
          if style == :single_quotes
            "Prefer single-quoted strings when you don't need string " \
            'interpolation or special symbols.'
          else
            'Prefer double-quoted strings unless you need single quotes to ' \
            'avoid extra backslashes for escaping.'
          end
        end

        def offense?(node)
          # If it's a string within an interpolation, then it's not an offense
          # for this cop.
          return false if inside_interpolation?(node)

          wrong_quotes?(node)
        end
      end
    end
  end
end
