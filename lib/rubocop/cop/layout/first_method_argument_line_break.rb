# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
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
              'multi-line method argument list.'.freeze

        def on_send(node)
          args = node.arguments

          # If there is a trailing hash arg without explicit braces, like this:
          #
          #    method(1, 'key1' => value1, 'key2' => value2)
          #
          # ...then each key/value pair is treated as a method 'argument'
          # when determining where line breaks should appear.
          if (last_arg = args.last)
            if last_arg.hash_type? && !last_arg.braces?
              args = args.concat(args.pop.children)
            end
          end

          check_method_line_break(node, args)
        end
        alias on_csend on_send

        def autocorrect(node)
          lambda do |corrector|
            first_arg = if node.argument?
                          node
                        else
                          # In case of keyword arguments
                          node.parent
                        end

            block_start_col = first_arg.parent.source_range.column

            corrector.insert_before(first_arg.source_range,
                                    "\n#{' ' * block_start_col}")
          end
        end
      end
    end
  end
end
