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
          expression, first_method, second_method, third_method = parse(node)

          return unless COUNTERS.include?(third_method)

          begin_pos = if SELECTORS.include?(first_method)
                        return if second_method.is_a?(Symbol)
                        expression.loc.selector.begin_pos
                      else
                        return unless SELECTORS.include?(second_method)
                        expression.parent.loc.selector.begin_pos
                      end

          return if node.parent && node.parent.block_type?

          range = Parser::Source::Range.new(node.loc.expression.source_buffer,
                                            begin_pos,
                                            node.loc.expression.end_pos)

          add_offense(node, range,
                      format(MSG, first_method || second_method, third_method))
        end

        def autocorrect(node)
          expression, first_method, second_method, = parse(node)

          return if first_method == :reject || second_method == :reject

          selector = if SELECTORS.include?(first_method)
                       expression.loc.selector
                     else
                       expression.parent.loc.selector
                     end

          @corrections << lambda do |corrector|
            range = Parser::Source::Range.new(node.loc.expression.source_buffer,
                                              node.loc.dot.begin_pos,
                                              node.loc.expression.end_pos)
            corrector.remove(range)
            corrector.replace(selector, 'count')
          end
        end

        private

        def parse(node)
          left, third_method = *node
          expression, second_method = *left
          _enumerable, first_method = *expression

          [expression, first_method, second_method, third_method]
        end
      end
    end
  end
end
