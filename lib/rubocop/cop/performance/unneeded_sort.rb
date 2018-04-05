# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify instances of sorting and then taking
      # only the first or last element.
      #
      # @example
      #   # bad
      #   [].sort.first
      #   [].sort_by(&:length).last
      #
      #   # good
      #   [].min
      #   [].max_by(&:length)
      class UnneededSort < Cop
        include RangeHelp

        MSG = 'Use `%<suggestion>s` instead of '\
              '`%<sorter>s...%<accessor_source>s`.'.freeze

        def_node_matcher :unneeded_sort?, <<-MATCHER
          {
            (send $(send _ $:sort ...) ${:last :first})
            (send $(send _ $:sort ...) ${:[] :at :slice} {(int 0) (int -1)})

            (send $(send _ $:sort_by _) ${:last :first})
            (send $(send _ $:sort_by _) ${:[] :at :slice} {(int 0) (int -1)})

            (send (block $(send _ ${:sort_by :sort}) ...) ${:last :first})
            (send
              (block $(send _ ${:sort_by :sort}) ...)
              ${:[] :at :slice} {(int 0) (int -1)}
            )
          }
        MATCHER

        def on_send(node)
          unneeded_sort?(node) do |sort_node, sorter, accessor|
            range = range_between(
              sort_node.loc.selector.begin_pos,
              node.loc.expression.end_pos
            )

            add_offense(node,
                        location: range,
                        message: message(node,
                                         sorter,
                                         accessor))
          end
        end

        def autocorrect(node)
          sort_node, sorter, accessor = unneeded_sort?(node)

          lambda do |corrector|
            # Remove accessor, e.g. `first` or `[-1]`.
            corrector.remove(
              range_between(
                accessor_start(node),
                node.loc.expression.end_pos
              )
            )

            # Replace "sort" or "sort_by" with the appropriate min/max method.
            corrector.replace(
              sort_node.loc.selector,
              suggestion(sorter, accessor, arg_value(node))
            )
          end
        end

        private

        def message(node, sorter, accessor)
          accessor_source = range_between(
            node.loc.selector.begin_pos,
            node.loc.expression.end_pos
          ).source

          format(MSG,
                 suggestion: suggestion(sorter,
                                        accessor,
                                        arg_value(node)),
                 sorter: sorter,
                 accessor_source: accessor_source)
        end

        def suggestion(sorter, accessor, arg)
          base(accessor, arg) + suffix(sorter)
        end

        def base(accessor, arg)
          if accessor == :first || (arg && arg.zero?)
            'min'
          elsif accessor == :last || arg == -1
            'max'
          end
        end

        def suffix(sorter)
          if sorter == :sort
            ''
          elsif sorter == :sort_by
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
