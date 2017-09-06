# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for unneeded `with_index`.
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
      class UnneededWithIndex < Cop
        MSG_EACH_WITH_INDEX = 'Use `each` instead of `each_with_index`.'.freeze
        MSG_WITH_INDEX = 'Remove unneeded `with_index`.'.freeze

        def_node_matcher :unneeded_with_index?, <<-PATTERN
          (block
            $(send
              _ {:each_with_index :with_index})
            (args
              (arg _))
            ...)
        PATTERN

        def on_block(node)
          unneeded_with_index?(node) do |send|
            add_offense(node, with_index_range(send))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            unneeded_with_index?(node) do |send|
              if each_with_index_method?(node)
                corrector.replace(send.loc.selector, 'each')
              else
                corrector.remove(send.loc.selector)
                corrector.remove(send.loc.dot)
              end
            end
          end
        end

        private

        def message(node)
          each_with_index_method?(node) ? MSG_EACH_WITH_INDEX : MSG_WITH_INDEX
        end

        def with_index_range(send)
          range_between(send.loc.selector.begin_pos, send.loc.selector.end_pos)
        end

        def each_with_index_method?(node)
          node.children.first.children.last == :each_with_index
        end
      end
    end
  end
end
