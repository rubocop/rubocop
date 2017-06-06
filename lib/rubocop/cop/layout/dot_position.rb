# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the . position in multi-line method calls.
      #
      # @example
      #   # bad
      #   something.
      #     mehod
      #
      #   # good
      #   something
      #     .method
      class DotPosition < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          return unless node.dot?

          if proper_dot_position?(node)
            correct_style_detected
          else
            add_offense(node, :dot) { opposite_style_detected }
          end
        end

        private

        def message(_node)
          'Place the . on the ' +
            case style
            when :leading
              'next line, together with the method name.'
            when :trailing
              'previous line, together with the method call receiver.'
            end
        end

        def proper_dot_position?(node)
          receiver_line = node.receiver.source_range.end.line
          selector_line = selector_range(node).line

          # receiver and selector are on the same line
          return true if selector_line == receiver_line

          dot_line = node.loc.dot.line

          # don't register an offense if there is a line comment between the
          # dot and the selector otherwise, we might break the code while
          # "correcting" it (even if there is just an extra blank line, treat
          # it the same)
          return true if line_between?(selector_line, dot_line)

          correct_dot_position_style?(dot_line, selector_line)
        end

        def line_between?(first_line, second_line)
          (first_line - second_line) > 1
        end

        def correct_dot_position_style?(dot_line, selector_line)
          case style
          when :leading then dot_line == selector_line
          when :trailing then dot_line != selector_line
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.loc.dot)
            case style
            when :leading
              corrector.insert_before(selector_range(node), '.')
            when :trailing
              corrector.insert_after(node.receiver.source_range, '.')
            end
          end
        end

        def selector_range(node)
          if node.loc.selector
            node.loc.selector
          else
            # l.(1) has no selector, so we use the opening parenthesis instead
            node.loc.begin
          end
        end
      end
    end
  end
end
