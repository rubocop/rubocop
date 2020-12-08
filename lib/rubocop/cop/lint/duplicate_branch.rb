# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks that there are no repeated bodies
      # within `if/unless`, `case-when` and `rescue` constructs.
      #
      # With `IgnoreLiteralBranches: true`, branches are not registered
      # as offenses if they return a basic literal value (string, symbol,
      # integer, float, rational, complex, `true`, `false`, or `nil`), or
      # return an array, hash, regexp or range that only contains one of
      # the above basic literal values.
      #
      # @example
      #   # bad
      #   if foo
      #     do_foo
      #     do_something_else
      #   elsif bar
      #     do_foo
      #     do_something_else
      #   end
      #
      #   # good
      #   if foo || bar
      #     do_foo
      #     do_something_else
      #   end
      #
      #   # bad
      #   case x
      #   when foo
      #     do_foo
      #   when bar
      #     do_foo
      #   else
      #     do_something_else
      #   end
      #
      #   # good
      #   case x
      #   when foo, bar
      #     do_foo
      #   else
      #     do_something_else
      #   end
      #
      #   # bad
      #   begin
      #     do_something
      #   rescue FooError
      #     handle_error
      #   rescue BarError
      #     handle_error
      #   end
      #
      #   # good
      #   begin
      #     do_something
      #   rescue FooError, BarError
      #     handle_error
      #   end
      #
      # @example IgnoreLiteralBranches: true
      #   # good
      #   case size
      #   when "small" then 100
      #   when "medium" then 250
      #   when "large" then 1000
      #   else 250
      #   end
      #
      class DuplicateBranch < Base
        include RescueNode

        MSG = 'Duplicate branch body detected.'

        def on_branching_statement(node)
          branches(node).each_with_object(Set.new) do |branch, previous|
            next unless consider_branch?(branch)

            add_offense(offense_range(branch)) unless previous.add?(branch)
          end
        end
        alias on_if on_branching_statement
        alias on_case on_branching_statement
        alias on_rescue on_branching_statement

        private

        def offense_range(duplicate_branch)
          parent = duplicate_branch.parent

          if parent.respond_to?(:else_branch) &&
             parent.else_branch.equal?(duplicate_branch)
            if parent.if_type? && parent.ternary?
              duplicate_branch.source_range
            else
              parent.loc.else
            end
          else
            parent.source_range
          end
        end

        def branches(node)
          node.branches.compact
        end

        def consider_branch?(branch)
          return true unless ignore_literal_branches?
          return true unless branch.literal?
          return false if branch.basic_literal?
          return true if branch.xstr_type?

          branch.each_descendant.any? do |node|
            next if node.pair_type? # hash keys and values are contained within a `pair` node

            !node.basic_literal?
          end
        end

        def ignore_literal_branches?
          cop_config.fetch('IgnoreLiteralBranches', false)
        end
      end
    end
  end
end
