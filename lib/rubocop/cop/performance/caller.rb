# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `caller[n]`
      # can be replaced by `caller(n..n).first`.
      #
      # @example
      #   # bad
      #   caller[1]
      #   caller.first
      #   caller_locations[1]
      #   caller_locations.first
      #
      #   # good
      #   caller(2..2).first
      #   caller(1..1).first
      #   caller_locations(2..2).first
      #   caller_locations(1..1).first
      class Caller < Cop
        MSG_BRACE = 'Use `%<method>s(%<n>d..%<n>d).first`' \
                    ' instead of `%<method>s[%<m>d]`.'.freeze
        MSG_FIRST = 'Use `%<method>s(%<n>d..%<n>d).first`' \
                    ' instead of `%<method>s.first`.'.freeze

        def_node_matcher :slow_caller?, <<-PATTERN
          {
            (send nil {:caller :caller_locations})
            (send nil {:caller :caller_locations} int)
          }
        PATTERN

        def_node_matcher :caller_with_scope_method?, <<-PATTERN
          {
            (send #slow_caller? :first)
            (send #slow_caller? :[] int)
          }
        PATTERN

        def on_send(node)
          return unless caller_with_scope_method?(node)

          add_offense(node)
        end

        private

        def message(node)
          method_name = node.receiver.method_name
          caller_arg = node.receiver.first_argument
          n = caller_arg ? int_value(caller_arg) : 1

          if node.method_name == :[]
            m = int_value(node.first_argument)
            n += m
            format(MSG_BRACE, n: n, m: m, method: method_name)
          else
            format(MSG_FIRST, n: n, method: method_name)
          end
        end

        def int_value(node)
          node.children[0]
        end
      end
    end
  end
end
