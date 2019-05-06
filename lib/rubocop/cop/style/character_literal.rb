# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of the character literal ?x.
      #
      # @example
      #   # bad
      #   ?x
      #
      #   # good
      #   'x'
      #
      #   # good
      #   ?\C-\M-d
      class CharacterLiteral < Cop
        include StringHelp

        MSG = 'Do not use the character literal - ' \
              'use string literal instead.'

        def offense?(node)
          # we don't register an offense for things like ?\C-\M-d
          node.loc.begin.is?('?') &&
            node.source.size.between?(2, 3)
        end

        def autocorrect(node)
          lambda do |corrector|
            string = node.source[1..-1]

            # special character like \n
            # or ' which needs to use "" or be escaped.
            if string.length == 2 || string == "'"
              corrector.replace(node.source_range, %("#{string}"))
            elsif string.length == 1 # normal character
              corrector.replace(node.source_range, "'#{string}'")
            end
          end
        end

        # Dummy implementation of method in ConfigurableEnforcedStyle that is
        # called from StringHelp.
        def opposite_style_detected; end

        # Dummy implementation of method in ConfigurableEnforcedStyle that is
        # called from StringHelp.
        def correct_style_detected; end
      end
    end
  end
end
