# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for unparenthesized method calls in the argument list
      # of a parenthesized method call.
      #
      # @example
      #   @good
      #   method1(method2(arg), method3(arg))
      #
      #   @bad
      #   method1(method2 arg, method3, arg)
      class NestedParenthesizedCalls < Cop
        MSG = 'Add parentheses to nested method call `%s`.'.freeze

        def on_send(node)
          return unless node.parenthesized?

          node.each_child_node(:send) do |nested|
            next if allowed_omission?(nested)

            add_offense(nested, nested.source_range, format(MSG, nested.source))
          end
        end

        private

        def allowed_omission?(send_node)
          !send_node.arguments? || send_node.parenthesized? ||
            send_node.setter_method? || send_node.operator_method? ||
            whitelisted?(send_node)
        end

        def whitelisted?(send_node)
          send_node.parent.arguments.one? &&
            whitelisted_methods.include?(send_node.method_name.to_s) &&
            send_node.arguments.one?
        end

        def autocorrect(nested)
          first_arg = nested.first_argument.source_range
          last_arg = nested.last_argument.source_range

          leading_space =
            range_with_surrounding_space(first_arg, :left).begin.resize(1)

          lambda do |corrector|
            corrector.replace(leading_space, '(')
            corrector.insert_after(last_arg, ')')
          end
        end

        def whitelisted_methods
          cop_config['Whitelist'] || []
        end
      end
    end
  end
end
