# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of the character literal ?x.
      class CharacterLiteral < Cop
        include StringHelp

        MSG = 'Do not use the character literal - use string literal instead.'

        def offence?(node)
          # we don't register an offence for things like ?\C-\M-d
          node.loc.begin.is?('?') &&
            node.loc.expression.source.size.between?(2, 3)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            string = node.loc.expression.source[1..-1]

            if string.length == 1 # normal character
              corrector.replace(node.loc.expression, "'#{string}'")
            elsif string.length == 2 # special character like \n
              corrector.replace(node.loc.expression, %Q("#{string}"))
            end
          end
        end
      end
    end
  end
end
