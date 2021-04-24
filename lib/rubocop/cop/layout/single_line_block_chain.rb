# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks if method calls are chained onto single line blocks. It considers that a
      # line break before the dot improves the readability of the code.
      #
      # @example
      #   # bad
      #   example.select { |item| item.cond? }.join('-')
      #
      #   # good
      #   example.select { |item| item.cond? }
      #          .join('-')
      #
      #   # good (not a concern for this cop)
      #   example.select do |item|
      #     item.cond?
      #   end.join('-')
      #
      class SingleLineBlockChain < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Put method call on a separate line if chained to a single line block.'

        def on_send(node)
          range = offending_range(node)
          add_offense(range) { |corrector| corrector.insert_before(range, "\n") } if range
        end

        private

        def offending_range(node)
          receiver = node.receiver
          return unless receiver&.block_type?

          receiver_location = receiver.loc
          closing_block_delimiter_line_number = receiver_location.end.line
          return if receiver_location.begin.line < closing_block_delimiter_line_number

          node_location = node.loc
          dot_range = node_location.dot
          return unless dot_range
          return if dot_range.line > closing_block_delimiter_line_number

          range_between(dot_range.begin_pos, node_location.selector.end_pos)
        end
      end
    end
  end
end
