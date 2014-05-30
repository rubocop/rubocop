# encoding: utf-8

module RuboCop
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
        MSG = 'Use `\\` instead of `+` or `<<` to concatenate those strings.'

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

        def concat?(method)
          [:+, :<<].include?(method)
        end

        def offending_node?(node)
          receiver, method, first_arg = *node

          return false unless concat?(method)

          return false unless final_node_is_string_type?(receiver)

          return false unless root_node_is_string_type?(first_arg)

          expression = node.loc.expression.source
          concatenator_at_line_end?(expression)
        end

        def concatenator_at_line_end?(expression)
          # check if the first line of the expression ends with a + or a <<
          expression =~ /.+(\+|<<)\s*$/
        end

        def string_type?(node)
          return false unless [:str, :dstr].include?(node.type)
          # strings like __FILE__ are of no interest
          return false unless node.loc.respond_to?(:begin)

          # we care only about quotes-delimited literals
          node.loc.begin && ["'", '"'].include?(node.loc.begin.source)
        end

        def final_node_is_string_type?(node)
          if node.type == :send
            _, method, first_arg = *node
            concat?(method) && final_node_is_string_type?(first_arg)
          else
            string_type?(node)
          end
        end

        def root_node_is_string_type?(node)
          if node.type == :send
            receiver, method, _ = *node
            concat?(method) && root_node_is_string_type?(receiver)
          else
            string_type?(node)
          end
        end
      end
    end
  end
end
