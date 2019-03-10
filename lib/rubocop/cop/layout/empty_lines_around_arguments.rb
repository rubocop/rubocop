# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks if empty lines exist around the arguments
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
        include RangeHelp

        MSG = 'Empty line detected around arguments.'.freeze

        def on_send(node)
          return if node.single_line? || node.arguments.empty?

          extra_lines(node) { |range| add_offense(node, location: range) }
        end
        alias on_csend on_send

        def autocorrect(node)
          lambda do |corrector|
            extra_lines(node) { |range| corrector.remove(range) }
          end
        end

        private

        def empty_lines(node)
          lines = processed_lines(node)
          lines.select! { |code, _| code.empty? }
          lines.map { |_, line| line }
        end

        def extra_lines(node)
          empty_lines(node).each do |line|
            range = source_range(processed_source.buffer, line, 0)
            yield(range)
          end
        end

        def processed_lines(node)
          line_numbers(node).each_with_object([]) do |num, array|
            array << [processed_source.lines[num - 1], num]
          end
        end

        def line_numbers(node)
          inner_lines = []
          line_nums = node.arguments.each_with_object([]) do |arg_node, lines|
            lines << outer_lines(arg_node)
            inner_lines << inner_lines(arg_node) if arg_node.multiline?
          end
          line_nums.flatten.uniq - inner_lines.flatten - outer_lines(node)
        end

        def inner_lines(node)
          [node.first_line + 1, node.last_line - 1]
        end

        def outer_lines(node)
          [node.first_line - 1, node.last_line + 1]
        end
      end
    end
  end
end
