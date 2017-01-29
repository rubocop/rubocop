# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks whether constant are relative date.
      #
      # @example
      #   # bad
      #   class SomeClass
      #     EXPIRED_AT = 1.week.since
      #   end
      #
      #   # good
      #   class SomeClass
      #     def self.expired_at
      #       1.week.since
      #     end
      #   end
      class RelativeDateConstant < Cop
        MSG = 'Do not use `%s` in constant variable, because they ' \
              'are evaluated only once at system running.'.freeze

        BAD_METHODS = %i(ago from_now since until).freeze

        def on_casgn(node)
          value = node.child_nodes.last
          check(value)
        end

        private

        def check(node)
          if bad_method_without_args?(node)
            add_offense(node, :expression, format(MSG, node.method_name))
          else
            node.each_child_node { |n| check(n) }
          end
        end

        def bad_method_without_args?(node)
          node.send_type? &&
            BAD_METHODS.include?(node.method_name) &&
            node.method_args.empty?
        end
      end
    end
  end
end
