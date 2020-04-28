# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for redundant `with_object`.
      #
      # @example
      #   # bad
      #   ary.each_with_object([]) do |v|
      #     v
      #   end
      #
      #   # good
      #   ary.each do |v|
      #     v
      #   end
      #
      #   # bad
      #   ary.each.with_object([]) do |v|
      #     v
      #   end
      #
      #   # good
      #   ary.each do |v|
      #     v
      #   end
      #
      class RedundantWithObject < Cop
        include RangeHelp

        MSG_EACH_WITH_OBJECT = 'Use `each` instead of `each_with_object`.'

        MSG_WITH_OBJECT = 'Remove redundant `with_object`.'

        def_node_matcher :redundant_with_object?, <<~PATTERN
          (block
            $(send _ {:each_with_object :with_object}
              _)
            (args
              (arg _))
            ...)
        PATTERN

        def on_block(node)
          redundant_with_object?(node) do |send|
            add_offense(node, location: with_object_range(send))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            redundant_with_object?(node) do |send|
              if send.method?(:each_with_object)
                corrector.replace(with_object_range(send), 'each')
              else
                corrector.remove(with_object_range(send))
                corrector.remove(send.loc.dot)
              end
            end
          end
        end

        private

        def message(node)
          if node.method?(:each_with_object)
            MSG_EACH_WITH_OBJECT
          else
            MSG_WITH_OBJECT
          end
        end

        def with_object_range(send)
          range_between(
            send.loc.selector.begin_pos,
            send.loc.expression.end_pos
          )
        end
      end
    end
  end
end
