# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiteralsInInterpolation < Cop
        include ConfigurableEnforcedStyle
        include StringHelp

        private

        def message(*)
          # single_quotes -> single-quoted
          kind = style.to_s.sub(/_(.*)s/, '-\1d')

          "Prefer #{kind} strings inside interpolations."
        end

        def offense?(node)
          # If it's not a string within a dynamic string, i.e. part of an
          # expression in an interpolation, then it's not an offense for this
          # cop.
          return false unless node.each_ancestor.find do |a|
            a.type == :dstr && within_node?(node, a)
          end

          src = node.loc.expression.source
          return false if src.start_with?('%') || src.start_with?('?')
          if style == :single_quotes
            src !~ /'/ && src !~ StringHelp::ESCAPED_CHAR_REGEXP
          else
            src !~ /" | \\/x
          end
        end

        def within_node?(inner, outer)
          o, i = outer.loc.expression, inner.loc.expression
          i.begin_pos >= o.begin_pos && i.end_pos <= o.end_pos
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
