# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiterals < Cop
        include ConfigurableEnforcedStyle
        include StringHelp

        private

        def message(node)
          if style == :double_quotes
            'Prefer double-quoted strings unless you need single quotes to ' \
            'avoid extra backslashes for escaping.'
          else
            m = if style == :static && node.loc.expression.source =~ /^.+'.+$/
                  'Prefer %q strings when the string contains a single ' \
                  'quote but '
                else
                  'Prefer single-quoted strings when '
                end
            m + "you don't need string interpolation or special symbols."
          end
        end

        def offense?(node)
          src = node.loc.expression.source
          return false if src =~ /^(%q|\?|<<-)/
          return false if style != :static && src =~ /^%/
          case style
          when :single_quotes
            src !~ /'/ && src !~ StringHelp::ESCAPED_CHAR_REGEXP
          when :static
            src =~ /^["%]/ && src !~ StringHelp::ESCAPED_CHAR_REGEXP
          else
            src !~ /" | \\/x
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            replacement = if style == :static
                            node.loc.expression.source =~ /'/ ? '%q(' : "'"
                          else
                            node.loc.begin.is?('"') ? "'" : '"'
                          end
            corrector.replace(node.loc.begin, replacement)
            replacement = ')' if replacement == '%q('
            corrector.replace(node.loc.end, replacement)
          end
        end
      end
    end
  end
end
