# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `sort { |a, b| a.foo <=> b.foo }`
      # can be replaced by `sort_by(&:foo)`.
      #
      # @example
      #   @bad
      #   array.sort { |a, b| a.foo <=> b.foo }
      #
      #   @good
      #   array.sort_by(&:foo)
      #   array.sort_by { |v| v.foo }
      #   array.sort_by do |var|
      #     var.foo
      #   end
      class SortWithBlock < Cop
        MSG = 'Use `sort_by(&:%s)` instead of ' \
              '`sort { |%s, %s| %s.%s <=> %s.%s }`.'.freeze

        def_node_matcher :sort, <<-END
          (block $(send _ :sort) (args (arg $_a) (arg $_b)) (send (send (lvar _a) $_m) :<=> (send (lvar _b) $_m)))
        END

        def on_block(node)
          sort(node) do |send, var_a, var_b, method|
            range = sort_range(send, node)
            add_offense(node, range,
                        format(MSG, method, var_a, var_b,
                               var_a, method, var_b, method))
          end
        end

        def autocorrect(node)
          send, = *node

          lambda do |corrector|
            method = node.children.last.children.last.children.last
            corrector.replace(sort_range(send, node), "sort_by(&:#{method})")
          end
        end

        private

        def sort_range(send, node)
          range_between(send.loc.selector.begin_pos, node.loc.end.end_pos)
        end
      end
    end
  end
end
