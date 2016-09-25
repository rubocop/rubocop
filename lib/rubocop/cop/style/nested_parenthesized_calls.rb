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
        RSPEC_MATCHERS = [:be, :eq, :eql, :equal, :be_kind_of, :be_instance_of,
                          :respond_to, :be_between, :match, :be_within,
                          :start_with, :end_with, :include, :raise_error].freeze

        def on_send(node)
          return unless parenthesized_call?(node)

          node.each_child_node(:send) do |nested|
            next if nested.method_args.empty? ||
                    parenthesized_call?(nested) ||
                    operator?(nested.method_name) ||
                    rspec_matcher?(node, nested) ||
                    nested.asgn_method_call?
            add_offense(nested, nested.source_range, format(MSG, nested.source))
          end
        end

        private

        def rspec_matcher?(parent, send)
          parent.method_args.one? && # .to, .not_to, etc
            RSPEC_MATCHERS.include?(send.method_name) &&
            send.method_args.one?
        end

        def autocorrect(nested)
          _scope, _method_name, *args = *nested

          first_arg = args.first.source_range
          last_arg = args.last.source_range

          first_arg_with_space = range_with_surrounding_space(first_arg, :left)
          leading_space = first_arg_with_space.begin.resize(1)

          lambda do |corrector|
            corrector.replace(leading_space, '(')
            corrector.insert_after(last_arg, ')')
          end
        end
      end
    end
  end
end
