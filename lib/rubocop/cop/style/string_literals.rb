# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiterals < Cop
        include StringHelp

        private

        def message(node)
          if single_quotes_preferred?
            "Prefer single-quoted strings when you don't need string " +
              'interpolation or special symbols.'
          else
            'Prefer double-quoted strings unless you need single quotes to ' +
              'avoid extra backslashes for escaping.'
          end
        end

        def offence?(node)
          src = node.loc.expression.source
          return false if src =~ /^%q/i
          src !~ if single_quotes_preferred?
                   # regex matches IF there is a ' or there is a \\ in the
                   # string that is not preceeded/followed by another \\
                   # (e.g. "\\x34") but not "\\\\"
                   /' | (?<! \\) \\{2}* \\ (?! \\)/x
                 else
                   /" | \\/x
                 end
        end

        def single_quotes_preferred?
          case cop_config['EnforcedStyle']
          when 'single_quotes' then true
          when 'double_quotes' then false
          else fail 'Unknown StringLiterals style'
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
