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
      #   #good
      #   a, b, = foo()
      #   a, = foo()
      #   *a, b, _ = foo()  => We need to know to not include 2 variables in a
      #   a, *b, _ = foo()  => The correction `a, *b, = foo()` is a syntax error
      class TrailingUnderscoreVariable < Cop
        include SurroundingSpace

        MSG = 'Do not use trailing `_`s in parallel assignment. ' \
              'Prefer `%s`.'.freeze
        UNDERSCORE = '_'.freeze

        def on_masgn(node)
          range = unneeded_range(node)

          return unless range

          good_code = node.source
          offset = range.begin_pos - node.source_range.begin_pos
          good_code[offset, range.size] = ''

          add_offense(node, range, format(MSG, good_code))
        end

        def autocorrect(node)
          range = unneeded_range(node)

          lambda do |corrector|
            corrector.remove(range) if range
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

        def unneeded_range(node)
          left, right = *node
          variables = *left
          first_offense = find_first_offense(variables)

          return unless first_offense

          end_position =
            if first_offense.source_range == variables.first.source_range
              right.source_range.begin_pos
            else
              node.loc.operator.begin_pos
            end

          range = range_between(first_offense.source_range.begin_pos,
                                end_position)
          range_with_surrounding_space(range, :right)
        end
      end
    end
  end
end
