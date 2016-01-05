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
      #   array.select(&:value).count
      #
      #   # good
      #   [1, 2, 3].count { |e| e > 2 }
      #   [1, 2, 3].count { |e| e < 2 }
      #   [1, 2, 3].count { |e| e > 2 && e.odd? }
      #   [1, 2, 3].count { |e| e < 2 && e.even? }
      #   Model.select('field AS field_one').count
      #   Model.select(:value).count
      class Count < Cop
        MSG = 'Use `count` instead of `%s...%s`.'

        SELECTORS = [:reject, :select]
        COUNTERS = [:count, :length, :size]

        def on_send(node)
          selector, selector_loc, params, counter = parse(node)
          return unless COUNTERS.include?(counter)
          return unless SELECTORS.include?(selector)
          return if params && !params.block_pass_type?
          return if node.parent && node.parent.block_type?

          range = Parser::Source::Range.new(node.source_range.source_buffer,
                                            selector_loc.begin_pos,
                                            node.source_range.end_pos)

          add_offense(node, range, format(MSG, selector, counter))
        end

        def autocorrect(node)
          selector, selector_loc = parse(node)

          return if selector == :reject

          range = Parser::Source::Range.new(node.source_range.source_buffer,
                                            node.loc.dot.begin_pos,
                                            node.source_range.end_pos)

          lambda do |corrector|
            corrector.remove(range)
            corrector.replace(selector_loc, 'count')
          end
        end

        private

        def parse(node)
          left, counter = *node
          expression, selector, params = *left

          selector_loc =
            if selector.is_a?(Symbol)
              if expression && expression.parent.loc.respond_to?(:selector)
                expression.parent.loc.selector
              elsif left.loc.respond_to?(:selector)
                left.loc.selector
              end
            else
              _enumerable, selector, params = *expression

              expression.loc.selector if contains_selector?(expression)
            end

          [selector, selector_loc, params, counter]
        end

        def contains_selector?(node)
          node.respond_to?(:loc) && node.loc.respond_to?(:selector)
        end
      end
    end
  end
end
