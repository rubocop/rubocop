# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for else branches that are unreachable if the if branch executes.
      # If the if branch unconditionally skips the execution of the else branch,
      # for example by returning early or skipping to the next iteration of the loop,
      # the else branch is redundant and its contents can be moved outside.
      #
      # @example
      #
      #   # bad
      #   if condition
      #     foo
      #     return
      #   else
      #     bar
      #   end
      #
      #   # good
      #   if condition
      #     foo
      #     return
      #   end
      #
      #   bar
      #
      class RedundantElse < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'This else branch is unreachable when the if branch executes.'
        CONTROL_FLOW = %w[return raise fail].freeze
        LOOP_CONTROL_FLOW = %w[next break redo].freeze

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def on_if(node)
          return unless !node.if_branch.nil? && node.else? && !node.else_branch.if_type?

          child_nodes = node.if_branch.child_nodes.filter_map do |node|
            node.source unless node.parent.if_type?
          end

          if (CONTROL_FLOW & child_nodes).any? ||
             ((LOOP_CONTROL_FLOW & child_nodes).any? && node.parent.block_type?)
            add_offense(node.loc.else) do |corrector|
              corrector.replace(node.loc.else, "end\n")
              corrector.remove(range_by_whole_lines(node.loc.end, include_final_newline: true))
            end
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      end
    end
  end
end
