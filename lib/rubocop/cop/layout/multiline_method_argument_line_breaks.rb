# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop ensures that each argument in a multi-line method call
      # starts on a separate line.
      #
      # @example
      #
      #   # bad
      #   foo(a, b,
      #     c
      #   )
      #
      #   # good
      #   foo(
      #     a,
      #     b,
      #     c
      #   )
      class MultilineMethodArgumentLineBreaks < Cop
        include(MultilineElementLineBreaks)

        MSG = 'Each argument in a multi-line method call must start ' \
          'on a separate line.'

        def on_send(node)
          return if node.method?(:[]=)

          args = node.arguments

          # If there is a trailing hash arg without explicit braces, like this:
          #
          #    method(1, 'key1' => value1, 'key2' => value2)
          #
          # ...then each key/value pair is treated as a method 'argument'
          # when determining where line breaks should appear.
          if (last_arg = args.last)
            args = args[0...-1] + last_arg.children if last_arg.hash_type? && !last_arg.braces?
          end

          check_line_breaks(node, args)
        end

        def autocorrect(node)
          EmptyLineCorrector.insert_before(node)
        end
      end
    end
  end
end
