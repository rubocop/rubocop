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
      #
      #   # good
      #   caller(2..2).first
      #   caller(1..1).first
      class Caller < Cop
        MSG_BRACE =
          'Use `caller(%<n>d..%<n>d).first` instead of `caller[%<m>d]`.'.freeze
        MSG_FIRST =
          'Use `caller(%<n>d..%<n>d).first` instead of `caller.first`.'.freeze

        def_node_matcher :slow_caller?, <<-PATTERN
          {
            (send nil :caller)
            (send nil :caller int)
          }
        PATTERN

        def_node_matcher :caller_with_scope_method?, <<-PATTERN
          {
            (send $_recv :first)
            (send $_recv :[] int)
          }
        PATTERN

        def on_send(node)
          recv = caller_with_scope_method?(node)
          return unless slow_caller?(recv)

          add_offense(node)
        end

        private

        def message(node)
          caller_arg = node.receiver.arguments[0]
          n = caller_arg ? int_value(caller_arg) : 1

          if node.method_name == :[]
            m = int_value(node.arguments[0])
            n += m
            format(MSG_BRACE, n: n, m: m)
          else
            format(MSG_FIRST, n: n)
          end
        end

        def int_value(node)
          node.children[0]
        end
      end
    end
  end
end
