# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # Place `when` conditions that use splat at the end
      # of the list of `when` branches.
      #
      # Ruby has to allocate memory for the splat expansion every time
      # that the `case` `when` statement is run. Since Ruby does not support
      # fall through inside of `case` `when`, like some other languages do,
      # the order of the `when` branches does not matter. By placing any
      # splat expansions at the end of the list of `when` branches we will
      # reduce the number of times that memory has to be allocated for
      # the expansion.
      #
      # This is not a guaranteed performance improvement. If the data being
      # processed by the `case` condition is normalized in a manner that favors
      # hitting a condition in the splat expansion, it is possible that
      # moving the splat condition to the end will use more memory,
      # and run slightly slower.
      #
      # @example
      #   # bad
      #   case foo
      #   when *condition
      #     bar
      #   when baz
      #     foobar
      #   end
      #
      #   case foo
      #   when *[1, 2, 3, 4]
      #     bar
      #   when 5
      #     baz
      #   end
      #
      #   # good
      #   case foo
      #   when baz
      #     foobar
      #   when *condition
      #     bar
      #   end
      #
      #   case foo
      #   when 1, 2, 3, 4
      #     bar
      #   when 5
      #     baz
      #   end
      class CaseWhenSplat < Cop
        include AutocorrectAlignment

        MSG = 'Place `when` conditions with a splat ' \
              'at the end of the `when` branches.'.freeze
        ARRAY_MSG = 'Do not expand array literals in `when` conditions.'.freeze
        OPEN_BRACKET = '['.freeze
        PERCENT_W = '%w'.freeze
        PERCENT_CAPITAL_W = '%W'.freeze
        PERCENT_I = '%i'.freeze
        PERCENT_CAPITAL_I = '%I'.freeze

        def initialize(*)
          super
          @reordered_splat_condition = false
        end

        def on_case(node)
          _case_branch, *when_branches, _else_branch = *node
          when_conditions =
            when_branches.each_with_object([]) do |branch, conditions|
              condition, = *branch
              conditions << condition
            end

          splat_offenses(when_conditions).reverse_each do |condition|
            range = condition.parent.loc.keyword.join(condition.source_range)
            variable, = *condition
            message = variable.array_type? ? ARRAY_MSG : MSG
            add_offense(condition.parent, range, message)
          end
        end

        def autocorrect(node)
          condition, = *node
          variable, = *condition
          if variable.array_type?
            correct_array_literal(condition, variable)
          else
            return if @reordered_splat_condition
            @reordered_splat_condition = true
            reorder_splat_condition(node)
          end
        end

        private

        def splat_offenses(when_conditions)
          found_non_splat = false
          when_conditions.reverse.each_with_object([]) do |condition, result|
            found_non_splat ||= error_condition?(condition)

            next unless condition.splat_type?
            result << condition if found_non_splat
          end
        end

        def error_condition?(condition)
          variable, = *condition

          (condition.splat_type? && variable.array_type?) ||
            !condition.splat_type?
        end

        def correct_array_literal(condition, variable)
          lambda do |corrector|
            array_start = variable.loc.begin.source

            if array_start.start_with?(OPEN_BRACKET)
              corrector.remove(condition.loc.operator)
              corrector.remove(variable.loc.begin)
              corrector.remove(variable.loc.end)
            else
              corrector.replace(condition.source_range,
                                expand_percent_array(variable))
            end
          end
        end

        def reorder_splat_condition(node)
          _case_branch, *when_branches, _else_branch = *node.parent
          current_index = when_branches.index { |branch| branch == node }
          next_branch = when_branches[current_index + 1]
          correction = "\n#{offset(node)}#{node.source}"
          range =
            Parser::Source::Range.new(node.parent,
                                      node.source_range.begin_pos,
                                      next_branch.source_range.begin_pos)

          lambda do |corrector|
            corrector.remove(range)
            corrector.insert_after(when_branches.last.source_range, correction)
          end
        end

        def expand_percent_array(array)
          array_start = array.loc.begin.source
          elements = *array
          elements = elements.map(&:source)

          if array_start.start_with?(PERCENT_W)
            "'#{elements.join("', '")}'"
          elsif array_start.start_with?(PERCENT_CAPITAL_W)
            %("#{elements.join('", "')}")
          elsif array_start.start_with?(PERCENT_I)
            ":#{elements.join(', :')}"
          elsif array_start.start_with?(PERCENT_CAPITAL_I)
            %(:"#{elements.join('", :"')}")
          end
        end
      end
    end
  end
end
