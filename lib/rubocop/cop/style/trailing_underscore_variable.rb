# encoding: utf-8

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
      class TrailingUnderscoreVariable < Cop
        include SurroundingSpace

        MSG = 'Do not use trailing `_`s in parallel assignment.'

        def on_masgn(node)
          left, = *node
          variables = *left
          first_offense = find_first_offense(variables)

          return if first_offense.nil?

          range =
            Parser::Source::Range.new(node.loc.expression.source_buffer,
                                      first_offense.loc.expression.begin_pos,
                                      variables.last.loc.expression.end_pos)
          add_offense(node, range)
        end

        def autocorrect(node)
          left, right = *node
          variables = *left
          first_offense = find_first_offense(variables)

          end_position =
            if first_offense.loc.expression == variables.first.loc.expression
              right.loc.expression.begin_pos
            else
              node.loc.operator.begin_pos
            end

          range =
            Parser::Source::Range.new(node.loc.expression.source_buffer,
                                      first_offense.loc.expression.begin_pos,
                                      end_position)

          ->(corrector) { corrector.remove(range) unless range.nil? }
        end

        private

        def find_first_offense(variables)
          first_offense = nil

          variables.reverse_each do |variable|
            break unless variable.children.first == :_
            first_offense = variable
          end

          first_offense
        end
      end
    end
  end
end
