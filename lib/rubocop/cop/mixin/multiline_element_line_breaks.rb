# frozen_string_literal: true

# TEAM: backend_infra
# WATCHERS: maxh

module RuboCop
  module Cop
    # Common functionality for checking for a line break before each
    # element in a multi-line collection.
    module MultilineElementLineBreaks
      private

      def check_line_breaks(_node, children)
        return if all_on_same_line?(children)

        last_seen_line = -1
        children.each do |child|
          if last_seen_line >= child.first_line
            add_offense(child) { |corrector| EmptyLineCorrector.insert_before(corrector, child) }
          else
            last_seen_line = child.last_line
          end
        end
      end

      def all_on_same_line?(nodes)
        return true if nodes.empty?

        nodes.first.first_line == nodes.last.last_line
      end
    end
  end
end
