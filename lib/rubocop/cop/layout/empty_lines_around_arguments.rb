# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks if empty lines exist around the arguments
      # of a method invocation.
      #
      # @example
      #   # bad
      #   do_something(
      #     foo
      #
      #   )
      #
      #   process(bar,
      #
      #           baz: qux,
      #           thud: fred)
      #
      #   some_method(
      #
      #     [1,2,3],
      #     x: y
      #   )
      #
      #   # good
      #   do_something(
      #     foo
      #   )
      #
      #   process(bar,
      #           baz: qux,
      #           thud: fred)
      #
      #   some_method(
      #     [1,2,3],
      #     x: y
      #   )
      #
      class EmptyLinesAroundArguments < Cop
        MSG = 'Empty line detected around arguments.'.freeze

        def on_send(node)
          return if node.single_line? || node.arguments.empty?
          extra_lines(node) { |range| add_offense(node, location: range) }
        end

        def autocorrect(node)
          lambda do |corrector|
            extra_lines(node) { |range| corrector.remove(range) }
          end
        end

        private

        def empty_lines(node)
          lines = processed_lines(node).map.with_index(first_line(node)).to_a
          lines.select! { |code, _| code.empty? }
          lines.map { |_, line| line }
        end

        def extra_lines(node)
          empty_lines(node).each do |line|
            range = source_range(processed_source.buffer, line, 0)
            yield(range)
          end
        end

        def first_line(node)
          node.receiver ? node.receiver.last_line : node.first_line
        end

        def last_line(node)
          last_arg = node.arguments.last
          last_arg.block_type? ? last_arg.first_line : node.last_line
        end

        def processed_lines(node)
          start = first_line(node) - 1
          stop = last_line(node) - 1
          processed_source.lines[start..stop]
        end
      end
    end
  end
end
