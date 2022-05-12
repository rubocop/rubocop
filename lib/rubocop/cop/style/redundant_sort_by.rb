# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Identifies places where `sort_by { ... }` can be replaced by
      # `sort`.
      #
      # @example
      #   # bad
      #   array.sort_by { |x| x }
      #   array.sort_by do |var|
      #     var
      #   end
      #
      #   # good
      #   array.sort
      class RedundantSortBy < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `sort` instead of `sort_by { |%<var>s| %<var>s }`.'

        # @!method redundant_sort_by(node)
        def_node_matcher :redundant_sort_by, <<~PATTERN
          (block $(send _ :sort_by) (args (arg $_x)) (lvar _x))
        PATTERN

        def on_block(node)
          redundant_sort_by(node) do |send, var_name|
            range = sort_by_range(send, node)

            add_offense(range, message: format(MSG, var: var_name)) do |corrector|
              corrector.replace(range, 'sort')
            end
          end
        end

        private

        def sort_by_range(send, node)
          range_between(send.loc.selector.begin_pos, node.loc.end.end_pos)
        end
      end
    end
  end
end
