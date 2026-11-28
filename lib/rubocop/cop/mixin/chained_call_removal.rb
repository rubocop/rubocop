# frozen_string_literal: true

module RuboCop
  module Cop
    # Finds the range of an argumentless chained call that can be removed without
    # joining other code to a comment or heredoc terminator.
    module ChainedCallRemoval
      include RangeHelp

      private

      def range_for_chained_call_removal(node)
        dot = node.loc.dot
        selector = node.loc.selector
        return unless selector.line == node.last_line && uninterrupted_chain?(dot, selector)

        call = dot.join(node.source_range.end)
        receiver = node.receiver.source_range
        return receiver.end.join(call) if uninterrupted_chain?(receiver, dot)

        separate_line_call_removal_range(call)
      end

      def uninterrupted_chain?(left, right)
        return true if left.last_line == right.line

        processed_source.first_token_of(left.end).begin_pos == right.begin_pos
      end

      def separate_line_call_removal_range(call)
        return unless begins_its_line?(call)

        rest = call.source_buffer.source_line(call.last_line)[call.last_column..].strip
        return range_by_whole_lines(call, include_final_newline: true) if rest.empty?

        call if rest.match?(/\A(#|&?\.(?!\.)|[)\]}])/)
      end
    end
  end
end
