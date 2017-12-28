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
          line_nums = line_numbers(node)
          line_nums.each_with_object([]) do |num, array|
            array << [processed_source.lines[num - 1], num]
          end
        end

        def line_numbers(node)
          line_nums = node.arguments.each_with_object([]) do |arg, array|
            array << arg.source_range.line - 1
            array << arg.source_range.end.line + 1
          end
          stay_inbounds(node, line_nums.uniq)
        end

        def stay_inbounds(node, line_nums)
          before_line = node.first_line - 1
          after_line = node.last_line + 1
          line_nums - [before_line, after_line]
        end
      end
    end
  end
end
