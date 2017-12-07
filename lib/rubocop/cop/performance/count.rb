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

        MSG = 'Use `count` instead of `%<selector>s...%<counter>s`.'.freeze

        def_node_matcher :count_candidate?, <<-PATTERN
          {
            (send (block $(send _ ${:select :reject}) ...) ${:count :length :size})
            (send $(send _ ${:select :reject} (:block_pass _)) ${:count :length :size})
          }
        PATTERN

        def on_send(node)
          return if rails_safe_mode?

          count_candidate?(node) do |selector_node, selector, counter|
            return unless eligible_node?(node)

            range = source_starting_at(node) do
              selector_node.loc.selector.begin_pos
            end

            add_offense(node,
                        location: range,
                        message: format(MSG, selector: selector,
                                             counter: counter))
          end
        end

        private

        def autocorrect(node)
          selector_node, selector, _counter = count_candidate?(node)
          selector_loc = selector_node.loc.selector

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

        def source_starting_at(node)
          begin_pos = if block_given?
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
