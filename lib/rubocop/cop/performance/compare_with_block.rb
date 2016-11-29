# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `sort { |a, b| a.foo <=> b.foo }`
      # can be replaced by `sort_by(&:foo)`.
      # This cop also checks `max` and `min` methods.
      #
      # @example
      #   @bad
      #   array.sort { |a, b| a.foo <=> b.foo }
      #   array.max { |a, b| a.foo <=> b.foo }
      #   array.min { |a, b| a.foo <=> b.foo }
      #
      #   @good
      #   array.sort_by(&:foo)
      #   array.sort_by { |v| v.foo }
      #   array.sort_by do |var|
      #     var.foo
      #   end
      #   array.max_by(&:foo)
      #   array.min_by(&:foo)
      class CompareWithBlock < Cop
        MSG = 'Use `%s_by(&:%s)` instead of ' \
              '`%s { |%s, %s| %s.%s <=> %s.%s }`.'.freeze

        def_node_matcher :compare?, <<-END
          (block $(send _ {:sort :min :max}) (args (arg $_a) (arg $_b)) (send (send (lvar _a) $_m) :<=> (send (lvar _b) $_m)))
        END

        def on_block(node)
          compare?(node) do |send, var_a, var_b, method|
            range = compare_range(send, node)
            compare_method = send.method_name
            add_offense(node, range,
                        format(MSG, compare_method, method,
                               compare_method, var_a, var_b,
                               var_a, method, var_b, method))
          end
        end

        def autocorrect(node)
          send, = *node

          lambda do |corrector|
            method = node.children.last.children.last.children.last
            corrector.replace(compare_range(send, node),
                              "#{send.method_name}_by(&:#{method})")
          end
        end

        private

        def compare_range(send, node)
          range_between(send.loc.selector.begin_pos, node.loc.end.end_pos)
        end
      end
    end
  end
end
