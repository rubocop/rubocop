# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks the . position in multi-line method calls.
      class DotPosition < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          return unless node.loc.dot

          if proper_dot_position?(node)
            correct_style_detected
          else
            add_offence(node, :dot) { opposite_style_detected }
          end
        end

        private

        def message(node)
          'Place the . on the ' +
            case style
            when :leading
              'next line, together with the method name.'
            when :trailing
              'previous line, together with the method call receiver.'
            end
        end

        def parameter_name
          'Style'
        end

        def proper_dot_position?(node)
          dot_line = node.loc.dot.line

          if node.loc.selector
            selector_line = node.loc.selector.line
          else
            # l.(1) has no selector, so we use the opening parenthesis instead
            selector_line = node.loc.begin.line
          end

          case style
          when :leading then dot_line == selector_line
          when :trailing then dot_line != selector_line || same_line?(node)
          end
        end

        def same_line?(node)
          node.loc.dot.line == node.loc.line
        end
      end
    end
  end
end
