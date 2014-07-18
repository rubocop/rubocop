# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiterals < Cop
        include ConfigurableEnforcedStyle
        include StringHelp

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
          src = node.loc.expression.source
          return false if src =~ /^(%[qQ]?|\?|<<-)/i
          if style == :single_quotes
            src !~ /'/ && src !~ StringHelp::ESCAPED_CHAR_REGEXP
          else
            src !~ /" | \\/x
          end
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
