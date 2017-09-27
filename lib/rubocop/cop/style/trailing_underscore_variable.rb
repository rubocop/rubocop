# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for extra underscores in variable assignment.
      #
      # @example
      #   # bad
      #   a, b, _ = foo()
      #   a, b, _, = foo()
      #   a, _, _ = foo()
      #   a, _, _, = foo()
      #
      #   # good
      #   a, b, = foo()
      #   a, = foo()
      #   *a, b, _ = foo()  => We need to know to not include 2 variables in a
      #   a, *b, _ = foo()  => The correction `a, *b, = foo()` is a syntax error
      #
      #   # good if AllowNamedUnderscoreVariables is true
      #   a, b, _something = foo()
      class TrailingUnderscoreVariable < Cop
        include SurroundingSpace

        MSG = 'Do not use trailing `_`s in parallel assignment. ' \
              'Prefer `%s`.'.freeze
        UNDERSCORE = '_'.freeze

        def on_masgn(node)
          ranges = unneeded_ranges(node)

          ranges.each do |range|
            good_code = node.source
            offset = range.begin_pos - node.source_range.begin_pos
            good_code[offset, range.size] = ''

            add_offense(node, location: range, message: format(MSG, good_code))
          end
        end

        def autocorrect(node)
          ranges = unneeded_ranges(node)

          lambda do |corrector|
            ranges.each { |range| corrector.remove(range) if range }
          end
        end

        private

        def find_first_offense(variables)
          first_offense = find_first_possible_offense(variables.reverse)

          return unless first_offense
          return if splat_variable_before?(first_offense, variables)

          first_offense
        end

        def find_first_possible_offense(variables)
          variables.reduce(nil) do |offense, variable|
            break offense unless %i[lvasgn splat].include?(variable.type)
            var, = *variable
            var, = *var
            if allow_named_underscore_variables
              break offense unless var == :_
            else
              break offense unless var.to_s.start_with?(UNDERSCORE)
            end

            variable
          end
        end

        def splat_variable_before?(first_offense, variables)
          # Account for cases like `_, *rest, _`, where we would otherwise get
          # the index of the first underscore.
          first_offense_index = reverse_index(variables, first_offense)

          variables[0...first_offense_index].any?(&:splat_type?)
        end

        def reverse_index(collection, item)
          collection.size - 1 - collection.reverse.index(item)
        end

        def allow_named_underscore_variables
          @allow_named_underscore_variables ||=
            cop_config['AllowNamedUnderscoreVariables']
        end

        def unneeded_ranges(node)
          node.masgn_type? ? (mlhs_node, = *node) : mlhs_node = node
          variables = *mlhs_node

          main_offense = main_node_offense(node)
          if main_offense.nil?
            children_offenses(variables)
          else
            children_offenses(variables) << main_offense
          end
        end

        def main_node_offense(node)
          node.masgn_type? ? (mlhs_node, right = *node) : mlhs_node = node

          variables = *mlhs_node
          first_offense = find_first_offense(variables)

          return unless first_offense

          if unused_variables_only?(first_offense, variables)
            return unused_range(node.type, mlhs_node, right)
          end

          if Util.parentheses?(mlhs_node)
            return range_for_parentheses(first_offense, mlhs_node)
          end

          range_between(first_offense.source_range.begin_pos,
                        node.loc.operator.begin_pos)
        end

        def children_offenses(variables)
          variables.select(&:mlhs_type?).flat_map { |v| unneeded_ranges(v) }
        end

        def unused_variables_only?(offense, variables)
          offense.source_range == variables.first.source_range
        end

        def unused_range(node_type, mlhs_node, right)
          start_range = mlhs_node.source_range.begin_pos

          end_range = case node_type
                      when :masgn
                        right.source_range.begin_pos
                      when :mlhs
                        mlhs_node.source_range.end_pos
                      end

          range_between(start_range, end_range)
        end

        def range_for_parentheses(offense, left)
          range_between(
            offense.source_range.begin_pos - 1,
            left.loc.expression.end_pos - 1
          )
        end
      end
    end
  end
end
