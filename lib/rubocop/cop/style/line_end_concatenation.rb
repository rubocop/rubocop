# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for string literal concatenation at
      # the end of a line.
      #
      # @example
      #
      #   # bad
      #   some_str = 'ala' +
      #              'bala'
      #
      #   some_str = 'ala' <<
      #              'bala'
      #
      #   # good
      #   some_str = 'ala' \
      #              'bala'
      #
      class LineEndConcatenation < Cop
        MSG = 'Use \\ instead of + to concatenate those strings.'

        def on_send(node)
          add_offense(node, :selector) if offending_node?(node)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            # replace + with \
            corrector.replace(node.loc.selector, '\\')
          end
        end

        private

        def offending_node?(node)
          receiver, method, arg = *node

          # TODO: Report Emacs bug.
          return false unless [:+, :<<].include?(method)

          return false unless string_type?(receiver)

          return false unless string_type?(arg)

          expression = node.loc.expression.source
          concatenator_at_line_end?(expression)
        end

        def concatenator_at_line_end?(expression)
          # check if the first line of the expression ends with a + or a <<
          expression =~ /.+(\+|<<)\s*$/
        end

        def string_type?(node)
          return false unless [:str, :dstr].include?(node.type)

          # we care only about quotes-delimited literals
          node.loc.begin && ["'", '"'].include?(node.loc.begin.source)
        end
      end
    end
  end
end
