# encoding: utf-8
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

        def parenthesized_call?(send)
          send.loc.begin && send.loc.begin.is?('(')
        end

        def rspec_matcher?(parent, send)
          parent.method_args.one? && # .to, .not_to, etc
            RSPEC_MATCHERS.include?(send.method_name) &&
            send.method_args.one?
        end
      end
    end
  end
end
