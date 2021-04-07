# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant `begin` blocks.
      #
      # Currently it checks for code like this:
      #
      # @example
      #
      #   # bad
      #   def redundant
      #     begin
      #       ala
      #       bala
      #     rescue StandardError => e
      #       something
      #     end
      #   end
      #
      #   # good
      #   def preferred
      #     ala
      #     bala
      #   rescue StandardError => e
      #     something
      #   end
      #
      #   # bad
      #   begin
      #     do_something
      #   end
      #
      #   # good
      #   do_something
      #
      #   # bad
      #   do_something do
      #     begin
      #       something
      #     rescue => ex
      #       anything
      #     end
      #   end
      #
      #   # good
      #   # In Ruby 2.5 or later, you can omit `begin` in `do-end` block.
      #   do_something do
      #     something
      #   rescue => ex
      #     anything
      #   end
      #
      #   # good
      #   # Stabby lambdas don't support implicit `begin` in `do-end` blocks.
      #   -> do
      #     begin
      #       foo
      #     rescue Bar
      #       baz
      #     end
      #   end
      class RedundantBegin < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Redundant `begin` block detected.'

        def on_def(node)
          return unless node.body&.kwbegin_type?

          register_offense(node.body)
        end
        alias on_defs on_def

        def on_block(node)
          return if node.send_node.lambda_literal?
          return if node.braces?
          return unless node.body&.kwbegin_type?

          register_offense(node.body)
        end

        def on_kwbegin(node)
          return if empty_begin?(node) ||
                    contain_rescue_or_ensure?(node) ||
                    valid_context_using_only_begin?(node)

          register_offense(node)
        end

        private

        def register_offense(node)
          offense_range = node.loc.begin

          add_offense(offense_range) do |corrector|
            if any_ancestor_assignment_node?(node)
              replace_begin_with_statement(corrector, offense_range, node)
            else
              corrector.remove(offense_range)
            end

            corrector.remove(node.loc.end)
          end
        end

        def replace_begin_with_statement(corrector, offense_range, node)
          first_child = node.children.first

          source = first_child.source
          source = "(#{source})" if first_child.if_type?

          corrector.replace(offense_range, source)
          corrector.remove(range_between(offense_range.end_pos, first_child.source_range.end_pos))

          restore_removed_comments(corrector, offense_range, node, first_child)
        end

        # Restore comments that occur between "begin" and "first_child".
        # These comments will be moved to above the assignment line.
        def restore_removed_comments(corrector, offense_range, node, first_child)
          comments_range = range_between(offense_range.end_pos, first_child.source_range.begin_pos)
          comments = comments_range.source

          corrector.insert_before(node.parent, comments) unless comments.blank?
        end

        def empty_begin?(node)
          node.children.empty?
        end

        def contain_rescue_or_ensure?(node)
          first_child = node.children.first

          first_child.rescue_type? || first_child.ensure_type?
        end

        def valid_context_using_only_begin?(node)
          parent = node.parent

          valid_begin_assignment?(node) || parent&.post_condition_loop? ||
            parent&.send_type? || parent&.operator_keyword?
        end

        def valid_begin_assignment?(node)
          any_ancestor_assignment_node?(node) && !node.children.one?
        end

        def any_ancestor_assignment_node?(node)
          node.each_ancestor.any?(&:assignment?)
        end
      end
    end
  end
end
