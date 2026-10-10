# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for places where multiple consecutive loops over the same data
      # can be combined into a single loop. It is very likely that combining them
      # will make the code more efficient and more concise.
      #
      # NOTE: Autocorrection is not applied when the block variable names differ in separate loops,
      # as it is impossible to determine which variable name should be prioritized.
      #
      # @safety
      #   The cop is unsafe, because the first loop might modify state that the
      #   second loop depends on; these two aren't combinable.
      #
      # @example
      #   # bad
      #   def method
      #     items.each do |item|
      #       do_something(item)
      #     end
      #
      #     items.each do |item|
      #       do_something_else(item)
      #     end
      #   end
      #
      #   # good
      #   def method
      #     items.each do |item|
      #       do_something(item)
      #       do_something_else(item)
      #     end
      #   end
      #
      #   # bad
      #   def method
      #     for item in items do
      #       do_something(item)
      #     end
      #
      #     for item in items do
      #       do_something_else(item)
      #     end
      #   end
      #
      #   # good
      #   def method
      #     for item in items do
      #       do_something(item)
      #       do_something_else(item)
      #     end
      #   end
      #
      #   # good
      #   def method
      #     each_slice(2) { |slice| do_something(slice) }
      #     each_slice(3) { |slice| do_something(slice) }
      #   end
      #
      class CombinableLoops < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Combine this loop with the previous loop.'

        def on_block(node)
          return unless node.parent&.begin_type?
          return unless collection_looping_method?(node)
          return unless combinable_looping_blocks?(node, node.left_sibling)

          add_offense(node) do |corrector|
            next unless combinable_blocks?(node, node.left_sibling)

            combine_with_left_sibling(corrector, node)
          end
        end

        alias on_numblock on_block
        alias on_itblock on_block

        def on_for(node)
          return unless node.parent&.begin_type?
          return unless same_collection_looping_for?(node, node.left_sibling)
          return unless node.body && node.left_sibling.body

          add_offense(node) do |corrector|
            next unless combinable_fors?(node, node.left_sibling)

            combine_with_left_sibling(corrector, node)
          end
        end

        private

        def collection_looping_method?(node)
          method_name = node.method_name
          method_name.start_with?('each') || method_name.end_with?('_each')
        end

        def same_collection_looping_block?(node, sibling)
          return false if sibling.nil? || !sibling.any_block_type?

          sibling.method?(node.method_name) &&
            sibling.receiver == node.receiver &&
            sibling.send_node.arguments == node.send_node.arguments
        end

        def combinable_looping_blocks?(node, sibling)
          same_collection_looping_block?(node, sibling) && node.body && sibling.body
        end

        def same_collection_looping_for?(node, sibling)
          sibling&.for_type? && node.collection == sibling.collection
        end

        def combinable_blocks?(node, sibling)
          return false unless node.arguments == sibling.arguments
          # Numbered and `it` parameters are implicit, so `arguments` is empty for both.
          return false unless node.argument_list == sibling.argument_list
          return false if directive_after_opening?(node)

          !node.body.type?(:rescue, :ensure) && !sibling.body.type?(:rescue, :ensure)
        end

        # Combining loops with different iteration variables would leave the second
        # body referencing an undefined variable, so only autocorrect when they match.
        def combinable_fors?(node, sibling)
          node.variable == sibling.variable && !directive_after_opening?(node)
        end

        # The opening is removed, so a directive after it would end up on a line of
        # its own, where it covers the rest of the file instead of a single line.
        def directive_after_opening?(node)
          opening_line = loop_opening(node).line
          return false if opening_line == node.body.first_line

          comment = processed_source.comment_at_line(opening_line)
          comment && DirectiveComment.new(comment).start_with_marker?
        end

        # The block arguments or `{`/`do` of a block, or the `do` or collection of a `for` loop.
        def loop_opening(node)
          if node.for_type?
            node.loc.begin || node.collection.source_range
          else
            (node.block_type? && node.arguments.source_range) || node.loc.begin
          end
        end

        def combine_with_left_sibling(corrector, node)
          corrector.remove(closing_with_preceding_space(node.left_sibling, node))
          corrector.remove(opening_with_following_space(node))

          correct_end_of_block(corrector, node)
        end

        # Comments and heredoc bodies before the closing delimiter are kept. When
        # the next loop starts on the delimiter's line, the line break before the
        # delimiter is kept too, so that a comment doesn't swallow the next loop.
        def closing_with_preceding_space(loop, next_loop)
          separate_lines = !same_line?(loop.loc.end, next_loop)

          range_with_surrounding_space(
            loop.loc.end, side: :left, newlines: separate_lines, whitespace: separate_lines
          )
        end

        # Comments between the opening and the body are kept.
        def opening_with_following_space(node)
          opening = node.source_range.begin.join(loop_opening(node))

          range_with_surrounding_space(opening, side: :right, whitespace: true)
        end

        def correct_end_of_block(corrector, node)
          return unless node.left_sibling.respond_to?(:braces?)
          return if combined_with_right_sibling?(node)

          end_of_block = first_combined_block(node).braces? ? '}' : ' end'
          corrector.remove(node.loc.end)
          corrector.insert_before(node.source_range.end, end_of_block)
        end

        def combined_with_right_sibling?(node)
          sibling = node.right_sibling
          return false unless sibling&.any_block_type?
          # A disabled loop isn't corrected, so it doesn't get merged into this one.
          return false unless enabled_lines?(sibling.source_range)

          same_collection_looping_block?(sibling, node) && sibling.body &&
            combinable_blocks?(sibling, node)
        end

        def first_combined_block(node)
          first = node.left_sibling

          while (previous = first.left_sibling) && enabled_lines?(first.source_range) &&
                combinable_looping_blocks?(first, previous) && combinable_blocks?(first, previous)
            first = previous
          end

          first
        end
      end
    end
  end
end
