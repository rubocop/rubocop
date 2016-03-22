# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of `count` on an `Enumerable` that
      # follow calls to `select` or `reject`. Querying logic can instead be
      # passed to the `count` call.
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
      #
      # `ActiveRecord` compatibility:
      # `ActiveRecord` will ignore the block that is passed to `count`.
      # Other methods, such as `select`, will convert the association to an
      # array and then run the block on the array. A simple work around to
      # make `count` work with a block is to call `to_a.count {...}`.
      #
      # Example:
      #   Model.where(id: [1, 2, 3].select { |m| m.method == true }.size
      #
      #   becomes:
      #
      #   Model.where(id: [1, 2, 3]).to_a.count { |m| m.method == true }
      class Count < Cop
        MSG = 'Use `count` instead of `%s...%s`.'.freeze

        SELECTORS = [:reject, :select].freeze
        COUNTERS = [:count, :length, :size].freeze

        def on_send(node)
          return unless should_run?
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

        def should_run?
          !(cop_config['SafeMode'.freeze] ||
            config['Rails'.freeze] &&
            config['Rails'.freeze]['Enabled'.freeze])
        end

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
