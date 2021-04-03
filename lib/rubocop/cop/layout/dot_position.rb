# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the . position in multi-line method calls.
      #
      # @example EnforcedStyle: leading (default)
      #   # bad
      #   something.
      #     method
      #
      #   # good
      #   something
      #     .method
      #
      # @example EnforcedStyle: trailing
      #   # bad
      #   something
      #     .method
      #
      #   # good
      #   something.
      #     method
      class DotPosition < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        def on_send(node)
          return unless node.dot? || ampersand_dot?(node)

          return correct_style_detected if proper_dot_position?(node)

          opposite_style_detected
          dot = node.loc.dot
          message = message(dot)

          add_offense(dot, message: message) { |corrector| autocorrect(corrector, dot, node) }
        end
        alias on_csend on_send

        private

        def autocorrect(corrector, dot, node)
          corrector.remove(dot)
          case style
          when :leading
            corrector.insert_before(selector_range(node), dot.source)
          when :trailing
            corrector.insert_after(node.receiver, dot.source)
          end
        end

        def message(dot)
          "Place the #{dot.source} on the " +
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

        def selector_range(node)
          # l.(1) has no selector, so we use the opening parenthesis instead
          node.loc.selector || node.loc.begin
        end

        def ampersand_dot?(node)
          node.loc.respond_to?(:dot) && node.loc.dot && node.loc.dot.is?('&.')
        end
      end
    end
  end
end
