# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for places where multiple consecutive loops over the same data
      # can be combined into a single loop. It is very likely that combining them
      # will make the code more efficient and more concise.
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
        extend AutoCorrector

        include RangeHelp

        MSG = 'Combine this loop with the previous loop.'

        def on_block(node)
          return unless node.parent&.begin_type?
          return unless collection_looping_method?(node)
          return unless same_collection_looping_block?(node, node.left_sibling)
          return unless node.body && node.left_sibling.body

          add_offense(node) do |corrector|
            combine_with_left_sibling(corrector, node)
          end
        end

        alias on_numblock on_block

        def on_for(node)
          return unless node.parent&.begin_type?
          return unless same_collection_looping_for?(node, node.left_sibling)

          add_offense(node) do |corrector|
            combine_with_left_sibling(corrector, node)
          end
        end

        private

        def collection_looping_method?(node)
          method_name = node.method_name
          method_name.start_with?('each') || method_name.end_with?('_each')
        end

        def same_collection_looping_block?(node, sibling)
          return false if sibling.nil? || (!sibling.block_type? && !sibling.numblock_type?)

          sibling.method?(node.method_name) &&
            sibling.receiver == node.receiver &&
            sibling.send_node.arguments == node.send_node.arguments
        end

        def same_collection_looping_for?(node, sibling)
          sibling&.for_type? && node.collection == sibling.collection
        end

        def combine_with_left_sibling(corrector, node)
          corrector.replace(
            node.left_sibling.body,
            "#{node.left_sibling.body.source}\n#{node.body.source}"
          )
          corrector.remove(range_with_surrounding_space(range: node.source_range, side: :left))
        end
      end
    end
  end
end
