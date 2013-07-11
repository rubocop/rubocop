# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of the character literal ?x.
      class CharacterLiteral < Cop
        MSG = 'Do not use the character literal - use string literal instead.'

        def on_str(node)
          # Constants like __FILE__ are handled as strings,
          # but don't respond to begin.
          return unless node.loc.respond_to?(:begin)

          # we don't register an offence for things like ?\C-\M-d
          if node.loc.begin.is?('?') &&
              node.loc.expression.source.size.between?(2, 3)
            add_offence(:convention, node.loc.expression, MSG)
            do_autocorrect(node)
          end
        end

        alias_method :on_dstr, :ignore_node
        alias_method :on_regexp, :ignore_node

        def autocorrect_action(node)
          string = node.loc.expression.source[1..-1]

          if string.length == 1 # normal character
            replace(node.loc.expression, "'#{string}'")
          elsif string.length == 2 # special character like \n
            replace(node.loc.expression, %Q("#{string}"))
          end
        end
      end
    end
  end
end
