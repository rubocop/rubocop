# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of `count` on an
      # `Enumerable` and change them to `size`.
      #
      # @example
      #   # bad
      #   [1, 2, 3].select { |e| e > 2 }.size
      #   [1, 2, 3].reject { |e| e > 2 }.size
      #   [1, 2, 3].select { |e| e > 2 }.length
      #   [1, 2, 3].reject { |e| e > 2 }.length
      #   [1, 2, 3].select { |e| e > 2 }.count { |e| e.odd? }
      #   [1, 2, 3].reject { |e| e > 2 }.count { |e| e.even? }
      #
      #   # good
      #   [1, 2, 3].count { |e| e > 2 }
      #   [1, 2, 3].count { |e| e < 2 }
      #   [1, 2, 3].count { |e| e > 2 && e.odd? }
      #   [1, 2, 3].count { |e| e < 2 && e.even? }
      class Count < Cop
        MSG = 'Use `count` instead of `%s...%s`.'

        SELECTORS = [:reject, :select]
        COUNTERS = [:count, :length, :size]

        def on_send(node)
          left, second_method = *node
          expression, = *left
          _enumerable, first_method = *expression

          return unless COUNTERS.include?(second_method)
          return unless SELECTORS.include?(first_method)
          return if node.parent && node.parent.block_type?

          add_offense(node,
                      node.loc.selector,
                      format(MSG, first_method, second_method))
        end

        def autocorrect(node)
          left, = *node
          expression, = *left
          _enumerable, first_method = *expression

          return if first_method == :reject

          @corrections << lambda do |corrector|
            range = Parser::Source::Range.new(node.loc.expression.source_buffer,
                                              node.loc.dot.begin_pos,
                                              node.loc.expression.end_pos)
            corrector.remove(range)
            corrector.replace(expression.loc.selector, 'count')
          end
        end
      end
    end
  end
end
