# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for redundant `with_index`.
      #
      # @example
      #   # bad
      #   ary.each_with_index do |v|
      #     v
      #   end
      #
      #   # good
      #   ary.each do |v|
      #     v
      #   end
      #
      #   # bad
      #   ary.each.with_index do |v|
      #     v
      #   end
      #
      #   # good
      #   ary.each do |v|
      #     v
      #   end
      #
      class RedundantWithIndex < Cop
        include RangeHelp

        MSG_EACH_WITH_INDEX = 'Use `each` instead of `each_with_index`.'
        MSG_WITH_INDEX = 'Remove redundant `with_index`.'

        def_node_matcher :redundant_with_index?, <<-PATTERN
          (block
            $(send
              _ {:each_with_index :with_index} ...)
            (args
              (arg _))
            ...)
        PATTERN

        def on_block(node)
          redundant_with_index?(node) do |send|
            add_offense(node, location: with_index_range(send))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            redundant_with_index?(node) do |send|
              if send.method_name == :each_with_index
                corrector.replace(send.loc.selector, 'each')
              else
                corrector.remove(with_index_range(send))
                corrector.remove(send.loc.dot)
              end
            end
          end
        end

        private

        def message(node)
          if node.method_name == :each_with_index
            MSG_EACH_WITH_INDEX
          else
            MSG_WITH_INDEX
          end
        end

        def with_index_range(send)
          range_between(
            send.loc.selector.begin_pos,
            send.loc.expression.end_pos
          )
        end
      end
    end
  end
end
