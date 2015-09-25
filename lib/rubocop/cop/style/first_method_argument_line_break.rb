# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for a line break before the first argument in a
      # multi-line method call.
      #
      # @example
      #
      #     # bad
      #     method(foo, bar,
      #       baz)
      #
      #     # good
      #     method(
      #       foo, bar,
      #       baz)
      #
      #     # ignored
      #     method foo, bar,
      #       baz
      class FirstMethodArgumentLineBreak < Cop
        include FirstElementLineBreak

        MSG = 'Add a line break before the first argument of a ' \
              'multi-line method argument list.'

        def on_send(node)
          _receiver, _name, *args = *node

          check_method_line_break(node, args)
        end
      end
    end
  end
end
