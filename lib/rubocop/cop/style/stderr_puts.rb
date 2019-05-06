# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop identifies places where `$stderr.puts` can be replaced by
      # `warn`. The latter has the advantage of easily being disabled by,
      # the `-W0` interpreter flag or setting `$VERBOSE` to `nil`.
      #
      # @example
      #   # bad
      #   $stderr.puts('hello')
      #
      #   # good
      #   warn('hello')
      #
      class StderrPuts < Cop
        include RangeHelp

        MSG =
          'Use `warn` instead of `%<bad>s` to allow such output to be disabled.'

        def_node_matcher :stderr_puts?, <<-PATTERN
          (send
            {(gvar #stderr_gvar?) (const nil? :STDERR)}
            :puts $_
            ...)
        PATTERN

        def on_send(node)
          return unless stderr_puts?(node)

          add_offense(node, location: stderr_puts_range(node))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(stderr_puts_range(node), 'warn')
          end
        end

        private

        def message(node)
          format(MSG, bad: "#{node.receiver.source}.#{node.method_name}")
        end

        def stderr_gvar?(sym)
          sym == :$stderr
        end

        def stderr_puts_range(send)
          range_between(
            send.loc.expression.begin_pos,
            send.loc.selector.end_pos
          )
        end
      end
    end
  end
end
