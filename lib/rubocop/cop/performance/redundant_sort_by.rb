# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `sort_by { ... }` can be replaced by
      # `sort`.
      #
      # @example
      #   @bad
      #   array.sort_by { |x| x }
      #   array.sort_by do |var|
      #     var
      #   end
      #
      #   @good
      #   array.sort
      class RedundantSortBy < Cop
        MSG = 'Use `sort` instead of `sort_by { |%s| %s }`.'.freeze

        def_node_matcher :redundant_sort_by, <<-PATTERN
          (block $(send _ :sort_by) (args (arg $_x)) (lvar _x))
        PATTERN

        def on_block(node)
          redundant_sort_by(node) do |send, var_name|
            range = sort_by_range(send, node)

            add_offense(node,
                        location: range,
                        message: format(MSG, var_name, var_name))
          end
        end

        def autocorrect(node)
          send, = *node
          ->(corrector) { corrector.replace(sort_by_range(send, node), 'sort') }
        end

        private

        def sort_by_range(send, node)
          range_between(send.loc.selector.begin_pos, node.loc.end.end_pos)
        end
      end
    end
  end
end
