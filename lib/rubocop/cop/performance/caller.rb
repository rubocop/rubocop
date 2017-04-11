# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `caller[n]`
      # can be replaced by `caller(n..n).first`.
      #
      # @example
      #   # bad
      #   caller[n]
      #   caller.first
      #
      #   # good
      #   caller(n..n).first
      #   caller(1..1).first
      class Caller < Cop
        MSG = 'Use `caller(n..n)` instead of `caller[n]`.'.freeze
        SCOPE_METHODS = %i[first []].freeze

        def_node_matcher :caller_with_scope_method?, <<-PATTERN
          (send (send nil :caller ...) ${#{SCOPE_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def on_send(node)
          return unless caller_with_scope_method?(node) && slow_caller?(node)
          add_offense(node, :selector)
        end

        private

        def slow_caller?(node)
          arguments = node.receiver.arguments

          arguments.empty? ||
            (arguments.length == 1 && arguments[0].int_type?)
        end
      end
    end
  end
end
