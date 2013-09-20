# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of double quotes where single quotes would do.
      class StringLiterals < Cop
        include StringHelp

        MSG = "Prefer single-quoted strings when you don't need " +
          'string interpolation or special symbols.'

        def offence?(node)
          # regex matches IF there is a ' or there is a \\ in the string that
          # is not preceeded/followed by another \\ (e.g. "\\x34") but not
          # "\\\\"
          node.loc.expression.source !~ /' | (?<! \\) \\{2}* \\ (?! \\)/x &&
            node.loc.begin && node.loc.begin.is?('"')
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.begin, "'")
            corrector.replace(node.loc.end, "'")
          end
        end
      end
    end
  end
end
