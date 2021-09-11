# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      #
      # This cop checks for `IO.select` that is incompatible with Fiber Scheduler since Ruby 3.0.
      #
      # @example
      #
      #   # bad
      #   IO.select([io], [], [], timeout)
      #
      #   # good
      #   io.wait_readable(timeout)
      #
      #   # bad
      #   IO.select([], [io], [], timeout)
      #
      #   # good
      #   io.wait_writable(timeout)
      #
      class IncompatibleIoSelectWithFiberScheduler < Base
        extend AutoCorrector

        MSG = 'Use `%<preferred>s` instead of `%<current>s`.'
        RESTRICT_ON_SEND = %i[select].freeze

        # @!method io_select(node)
        def_node_matcher :io_select, <<~PATTERN
          (send
            (const {nil? cbase} :IO) :select $_ $_ {(array) nil} $...)
        PATTERN

        def on_send(node)
          return unless (read, write, timeout = io_select(node))
          return unless scheduler_compatible?(read, write) || scheduler_compatible?(write, read)

          preferred = preferred_method(read, write, timeout)
          message = format(MSG, preferred: preferred, current: node.source)

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, preferred)
          end
        end

        private

        def scheduler_compatible?(io1, io2)
          return false unless io1.array_type? && io1.values.size == 1

          io2.array_type? ? io2.values.empty? : io2.nil_type?
        end

        def preferred_method(read, write, timeout)
          timeout_argument = timeout.empty? ? '' : "(#{timeout[0].source})"

          if read.array_type? && read.values[0]
            "#{read.values[0].source}.wait_readable#{timeout_argument}"
          else
            "#{write.values[0].source}.wait_writable#{timeout_argument}"
          end
        end
      end
    end
  end
end
