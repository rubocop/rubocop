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
      #   # good
      #   some_str = 'ala' \
      #              'bala'
      #
      class LineEndConcatenation < Cop
        MSG = 'Use \\ instead of + to concatenate those strings.'

        def on_send(node)
          add_offence(node, :selector) if offending_node?(node)
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
          return false unless :+ == method

          return false unless receiver.type == :str

          return false unless arg.type == :str

          receiver_line = receiver.loc.expression.line
          arg_line = arg.loc.expression.line

          receiver_line != arg_line
        end
      end
    end
  end
end
