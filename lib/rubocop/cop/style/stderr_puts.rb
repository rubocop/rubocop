# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop identifies places where `$stderr.puts`
      # can be replaced by `warn`.
      #
      # @example
      #   # bad
      #   $stderr.puts('hello')
      #
      #   # good
      #   warn('hello')
      #
      class StderrPuts < Cop
        MSG = 'Use `warn` instead of `$stderr.puts`.'.freeze

        def_node_matcher :stderr_puts?, <<-PATTERN
          (send
            (gvar #stderr_gvar?) :puts
            ...)
        PATTERN

        def on_send(node)
          return unless stderr_puts?(node)

          add_offense(node, stderr_puts_range(node))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(stderr_puts_range(node), 'warn')
          end
        end

        private

        def stderr_gvar?(sym)
          sym == :$stderr
        end

        def stderr_puts_range(send)
          range_between(
            send.children.first.loc.expression.begin_pos,
            send.loc.selector.end_pos
          )
        end
      end
    end
  end
end
