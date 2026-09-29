# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for uses of `begin...end while/until something`.
      #
      # @safety
      #   The cop is unsafe because behavior can change in some cases, including
      #   if a local variable inside the loop body is accessed outside of it, or if the
      #   loop body raises a `StopIteration` exception (which `Kernel#loop` rescues).
      #
      # @example
      #
      #   # bad
      #
      #   # using while
      #   begin
      #     do_something
      #   end while some_condition
      #
      #   # good
      #
      #   # while replacement
      #   loop do
      #     do_something
      #     break unless some_condition
      #   end
      #
      #   # bad
      #
      #   # using until
      #   begin
      #     do_something
      #   end until some_condition
      #
      #   # good
      #
      #   # until replacement
      #   loop do
      #     do_something
      #     break if some_condition
      #   end
      class Loop < Base
        include Alignment
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).'

        def on_while_post(node)
          register_offense(node)
        end

        def on_until_post(node)
          register_offense(node)
        end

        private

        def register_offense(node)
          body = node.body

          add_offense(node.loc.keyword) do |corrector|
            corrector.replace(body.loc.begin, 'loop do')
            corrector.remove(keyword_and_condition_range(node))

            insert_break_line(corrector, node, body)
          end
        end

        def keyword_and_condition_range(node)
          node.body.loc.end.end.join(node.source_range.end)
        end

        def insert_break_line(corrector, node, body)
          if body.single_line?
            corrector.replace(space_before_end(body), build_break_line(node))
          else
            corrector.insert_before(body.loc.end, build_break_line(node))
          end
        end

        def space_before_end(body)
          range = range_with_surrounding_space(range: body.loc.end, side: :left, newlines: false)

          range.with(end_pos: body.loc.end.begin_pos)
        end

        def build_break_line(node)
          conditional_keyword = node.while_post_type? ? 'unless' : 'if'
          break_line = "break #{conditional_keyword} #{node.condition.source}\n#{indent(node)}"
          return break_line unless node.body.single_line?

          # A single-line `begin ... end` keeps its body and `end` on one line,
          # so the `break` has to start a line of its own.
          "\n#{indent(node, offset: configured_indentation_width)}#{break_line}"
        end
      end
    end
  end
end
