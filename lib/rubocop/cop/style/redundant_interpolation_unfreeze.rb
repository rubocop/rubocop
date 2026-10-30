# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Before Ruby 3.0, interpolated strings followed the frozen string literal
      # magic comment which sometimes made it necessary to explicitly unfreeze them.
      # Ruby 3.0 changed interpolated strings to always be unfrozen which makes
      # unfreezing them redundant.
      #
      # @example
      #   # bad
      #   +"#{foo} bar"
      #
      #   # bad
      #   "#{foo} bar".dup
      #
      #   # bad
      #   String.new("#{foo} bar")
      #
      #   # good
      #   "#{foo} bar"
      #
      class RedundantInterpolationUnfreeze < Base
        include FrozenStringLiteral
        extend AutoCorrector
        extend TargetRubyVersion

        MSG = "Don't unfreeze interpolated strings as they are already unfrozen."

        minimum_target_ruby_version 3.0

        def self.autocorrect_incompatible_with
          [Layout::MultilineMethodCallBraceLayout]
        end

        # @!method redundant_unfreeze?(node)
        def_node_matcher :redundant_unfreeze?, <<~PATTERN
          {
            (send dstr_type? {:+@ :dup})
            (send (const nil? :String) :new dstr_type?)
          }
        PATTERN

        def on_dstr(node)
          return if uninterpolated_string?(node) || uninterpolated_heredoc?(node)
          return unless redundant_unfreeze?(node.parent)
          return if comment_outside_string?(node)

          add_offense(offense_range(node.parent)) do |corrector|
            remove_unfreeze(corrector, node.parent, node)
          end
        end

        private

        def offense_range(node)
          if node.method?(:new)
            node.source_range.begin.join(node.loc.selector)
          else
            node.loc.selector
          end
        end

        # Only the parts around the string are removed, so that an unfrozen string
        # interpolated into it can be corrected in the same pass.
        def remove_unfreeze(corrector, node, string)
          corrector.remove(node.source_range.begin.join(string.source_range.begin))
          corrector.remove(string.source_range.end.join(node.source_range.end))
        end

        def comment_outside_string?(node)
          call_range = node.parent.source_range
          string_range = node.source_range

          processed_source.comments.any? do |comment|
            range = comment.source_range

            call_range.contains?(range) && !string_range.contains?(range)
          end
        end
      end
    end
  end
end
