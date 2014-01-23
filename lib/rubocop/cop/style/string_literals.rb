# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiterals < Cop
        include ConfigurableEnforcedStyle
        include StringHelp

        private

        def message(node)
          if style == :single_quotes
            "Prefer single-quoted strings when you don't need string " \
            'interpolation or special symbols.'
          else
            'Prefer double-quoted strings unless you need single quotes to ' \
            'avoid extra backslashes for escaping.'
          end
        end

        def offence?(node)
          src = node.loc.expression.source
          return false if src =~ /^(%[qQ]?|\?|<<-)/i
          src !~ if style == :single_quotes
                   # regex matches IF there is a ' or there is a \\ in the
                   # string that is not preceeded/followed by another \\
                   # (e.g. "\\x34") but not "\\\\"
                   /' | (?<! \\) \\{2}* \\ (?! \\)/x
                 else
                   /" | \\/x
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
