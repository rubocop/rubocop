# encoding: utf-8
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
          return unless (range = unneeded_range(node))

          good_code = node.source
          offset = range.begin_pos - node.source_range.begin_pos
          good_code[offset, range.size] = ''

          add_offense(node, range, format(MSG, good_code))
        end

        def autocorrect(node)
          lambda do |corrector|
            range = unneeded_range(node)
            corrector.remove(range) if range
          end
        end

        private

        def find_first_offense(variables)
          first_offense = nil

          variables.reverse_each do |variable|
            var, = *variable
            var, = *var
            if allow_named_underscore_variables
              break unless var == :_
            else
              break unless var.to_s.start_with?(UNDERSCORE)
            end
            first_offense = variable
          end

          return nil if first_offense.nil?

          first_offense_index = variables.index(first_offense)
          0.upto(first_offense_index - 1).each do |index|
            return nil if variables[index].splat_type?
          end

          first_offense
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

          range =
            Parser::Source::Range.new(node.source_range.source_buffer,
                                      first_offense.source_range.begin_pos,
                                      end_position)
          range_with_surrounding_space(range, :right)
        end
      end
    end
  end
end
