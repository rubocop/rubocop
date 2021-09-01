# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop is used to identify instances of sorting and then
      # taking only the first or last element. The same behavior can
      # be accomplished without a relatively expensive sort by using
      # `Enumerable#min` instead of sorting and taking the first
      # element and `Enumerable#max` instead of sorting and taking the
      # last element. Similarly, `Enumerable#min_by` and
      # `Enumerable#max_by` can replace `Enumerable#sort_by` calls
      # after which only the first or last element is used.
      #
      # @example
      #   # bad
      #   [2, 1, 3].sort.first
      #   [2, 1, 3].sort[0]
      #   [2, 1, 3].sort.at(0)
      #   [2, 1, 3].sort.slice(0)
      #
      #   # good
      #   [2, 1, 3].min
      #
      #   # bad
      #   [2, 1, 3].sort.last
      #   [2, 1, 3].sort[-1]
      #   [2, 1, 3].sort.at(-1)
      #   [2, 1, 3].sort.slice(-1)
      #
      #   # good
      #   [2, 1, 3].max
      #
      #   # bad
      #   arr.sort_by(&:foo).first
      #   arr.sort_by(&:foo)[0]
      #   arr.sort_by(&:foo).at(0)
      #   arr.sort_by(&:foo).slice(0)
      #
      #   # good
      #   arr.min_by(&:foo)
      #
      #   # bad
      #   arr.sort_by(&:foo).last
      #   arr.sort_by(&:foo)[-1]
      #   arr.sort_by(&:foo).at(-1)
      #   arr.sort_by(&:foo).slice(-1)
      #
      #   # good
      #   arr.max_by(&:foo)
      #
      class RedundantSort < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `%<suggestion>s` instead of `%<sorter>s...%<accessor_source>s`.'

        RESTRICT_ON_SEND = %i[sort sort_by].freeze

        # @!method redundant_sort?(node)
        def_node_matcher :redundant_sort?, <<~MATCHER
          {
            (send $(send _ $:sort) ${:last :first})
            (send $(send _ $:sort) ${:[] :at :slice} {(int 0) (int -1)})

            (send $(send _ $:sort_by _) ${:last :first})
            (send $(send _ $:sort_by _) ${:[] :at :slice} {(int 0) (int -1)})

            (send ({block numblock} $(send _ ${:sort_by :sort}) ...) ${:last :first})
            (send
              ({block numblock} $(send _ ${:sort_by :sort}) ...)
              ${:[] :at :slice} {(int 0) (int -1)}
            )
          }
        MATCHER

        def on_send(node)
          if (sort_node, sorter, accessor = redundant_sort?(node.parent))
            return if use_size_method_in_block?(sort_node)

            ancestor = node.parent
          elsif (sort_node, sorter, accessor = redundant_sort?(node.parent&.parent))
            return if use_size_method_in_block?(sort_node)

            ancestor = node.parent.parent
          else
            return
          end

          register_offense(ancestor, sort_node, sorter, accessor)
        end

        private

        def use_size_method_in_block?(sort_node)
          return true if sort_node.send_type? && sort_node.block_node&.body&.method?(:size)
          return false unless sort_node.block_argument?

          sort_node.last_argument.children.first.value == :size
        end

        def register_offense(ancestor, sort_node, sorter, accessor)
          message = message(ancestor, sorter, accessor)

          add_offense(offense_range(sort_node, ancestor), message: message) do |corrector|
            autocorrect(corrector, ancestor, sort_node, sorter, accessor)
          end
        end

        def autocorrect(corrector, node, sort_node, sorter, accessor)
          # Remove accessor, e.g. `first` or `[-1]`.
          corrector.remove(range_between(accessor_start(node), node.loc.expression.end_pos))

          # Replace "sort" or "sort_by" with the appropriate min/max method.
          corrector.replace(sort_node.loc.selector, suggestion(sorter, accessor, arg_value(node)))
        end

        def offense_range(sort_node, ancestor)
          range_between(sort_node.loc.selector.begin_pos, ancestor.loc.expression.end_pos)
        end

        def message(node, sorter, accessor)
          accessor_source = range_between(
            node.loc.selector.begin_pos,
            node.loc.expression.end_pos
          ).source

          format(MSG,
                 suggestion: suggestion(sorter, accessor, arg_value(node)),
                 sorter: sorter,
                 accessor_source: accessor_source)
        end

        def suggestion(sorter, accessor, arg)
          base(accessor, arg) + suffix(sorter)
        end

        def base(accessor, arg)
          if accessor == :first || arg&.zero?
            'min'
          elsif accessor == :last || arg == -1
            'max'
          end
        end

        def suffix(sorter)
          case sorter
          when :sort
            ''
          when :sort_by
            '_by'
          end
        end

        def arg_node(node)
          node.arguments.first
        end

        def arg_value(node)
          arg_node(node).nil? ? nil : arg_node(node).node_parts.first
        end

        # This gets the start of the accessor whether it has a dot
        # (e.g. `.first`) or doesn't (e.g. `[0]`)
        def accessor_start(node)
          if node.loc.dot
            node.loc.dot.begin_pos
          else
            node.loc.selector.begin_pos
          end
        end
      end
    end
  end
end
