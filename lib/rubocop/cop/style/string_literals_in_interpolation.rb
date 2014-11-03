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
          # offense for this cop. A :begin node inside a :dstr node is an
          # interpolation.
          begin_found = false
          return false unless node.each_ancestor.find do |a|
            begin_found = true if a.type == :begin
            begin_found && a.type == :dstr
          end

          wrong_quotes?(node, style)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            replacement = node.loc.begin.is?('"') ? "'" : '"'
            corrector.replace(node.loc.begin, replacement)
            corrector.replace(node.loc.end, replacement)
          end
        end
      end
    end
  end
end
