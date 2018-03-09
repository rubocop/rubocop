# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop checks for memoized methods whose instance variable name
      # does not match the method name.
      #
      # @example
      #   # bad
      #   # Method foo is memoized using an instance variable that is
      #   # not `@foo`. This can cause confusion and bugs.
      #   def foo
      #     @something ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def foo
      #     @foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def foo
      #     @foo ||= begin
      #       calculate_expensive_thing
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     helper_variable = something_we_need_to_calculate_foo
      #     @foo ||= calculate_expensive_thing(helper_variable)
      #   end
      #
      class MemoizedInstanceVariableName < Cop
        MSG = 'Memoized variable `%<var>s` does not match ' \
          'method name `%<method>s`. Use `@%<suggested_var>s` instead.'.freeze

        def self.node_pattern
          memo_assign = '(or_asgn $(ivasgn _) _)'
          memoized_at_end_of_method = "(begin ... #{memo_assign})"
          instance_method =
            "(def $_ _ {#{memo_assign} #{memoized_at_end_of_method}})"
          class_method =
            "(defs self $_ _ {#{memo_assign} #{memoized_at_end_of_method}})"
          "{#{instance_method} #{class_method}}"
        end

        private_class_method :node_pattern
        def_node_matcher :memoized?, node_pattern

        def on_def(node)
          (method_name, ivar_assign) = memoized?(node)
          return if matches?(method_name, ivar_assign)
          msg = format(
            MSG,
            var: ivar_assign.children.first.to_s,
            suggested_var: method_name.to_s.chomp('?'),
            method: method_name
          )
          add_offense(node, location: ivar_assign.source_range, message: msg)
        end
        alias on_defs on_def

        private

        def matches?(method_name, ivar_assign)
          return true if ivar_assign.nil? || method_name == :initialize
          method_name = method_name.to_s.sub('?', '')
          variable = ivar_assign.children.first
          variable_name = variable.to_s.sub('@', '')
          variable_name == method_name
        end
      end
    end
  end
end
