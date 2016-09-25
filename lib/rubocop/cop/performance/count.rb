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
        include SafeMode

        MSG = 'Use `count` instead of `%s...%s`.'.freeze

        SELECTORS = [:reject, :select].freeze
        COUNTERS = [:count, :length, :size].freeze

        def on_send(node)
          return if rails_safe_mode?

          @selector, @selector_loc, @params, @counter = parse(node)

          check(node)
        end

        private

        attr_reader :selector, :selector_loc, :params, :counter

        def check(node)
          return unless eligible_node?(node) && eligible_params? &&
                        eligible_method_chain?

          range = source_starting_at(node) { @selector_loc.begin_pos }

          add_offense(node, range, format(MSG, @selector, @counter))
        end

        def autocorrect(node)
          selector, selector_loc = parse(node)

          return if selector == :reject

          range = source_starting_at(node) { |n| n.loc.dot.begin_pos }

          lambda do |corrector|
            corrector.remove(range)
            corrector.replace(selector_loc, 'count')
          end
        end

        def eligible_node?(node)
          !(node.parent && node.parent.block_type?)
        end

        def eligible_params?
          !(params && !params.block_pass_type?)
        end

        def eligible_method_chain?
          COUNTERS.include?(counter) && SELECTORS.include?(selector)
        end

        def parse(node)
          head, counter = *node
          expression, selector, params = *head
          if selector.is_a?(Symbol)
            selector_loc = selector_location(expression, head.loc)
          else
            _, selector, params = *expression
            if contains_selector?(expression)
              selector_loc = expression.loc.selector
            end
          end

          [selector, selector_loc, params, counter]
        end

        def selector_location(expression, head_loc)
          if expression && expression.parent.loc.respond_to?(:selector)
            expression.parent.loc.selector
          elsif head_loc.respond_to?(:selector)
            head_loc.selector
          end
        end

        def contains_selector?(node)
          node.respond_to?(:loc) && node.loc.respond_to?(:selector)
        end

        def source_starting_at(node)
          begin_pos =
            if block_given?
              yield node
            else
              node.source_range.begin_pos
            end

          range_between(begin_pos, node.source_range.end_pos)
        end
      end
    end
  end
end
