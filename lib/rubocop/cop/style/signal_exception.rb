# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of `fail` and `raise`.
      class SignalException < Cop
        include ConfigurableEnforcedStyle

        FAIL_MSG = 'Use `fail` instead of `raise` to signal exceptions.'.freeze
        RAISE_MSG = 'Use `raise` instead of `fail` to ' \
                    'rethrow exceptions.'.freeze

        def_node_matcher :kernel_call?, '(send (const nil? :Kernel) %1 ...)'
        def_node_search :custom_fail_methods,
                        '{(def :fail ...) (defs _ :fail ...)}'

        def investigate(processed_source)
          ast = processed_source.ast
          @custom_fail_defined = ast && custom_fail_methods(ast).any?
        end

        def on_rescue(node)
          return unless style == :semantic

          begin_node, *rescue_nodes, _else_node = *node
          check_scope(:raise, begin_node)

          rescue_nodes.each do |rescue_node|
            check_scope(:fail, rescue_node)
            allow(:raise, rescue_node)
          end
        end

        def on_send(node)
          case style
          when :semantic
            check_send(:raise, node) unless ignored_node?(node)
          when :only_raise
            return if @custom_fail_defined
            check_send(:fail, node)
          when :only_fail
            check_send(:raise, node)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            name =
              case style
              when :semantic
                command_or_kernel_call?(:raise, node) ? 'fail' : 'raise'
              when :only_raise then 'raise'
              when :only_fail then 'fail'
              end

            corrector.replace(node.loc.selector, name)
          end
        end

        private

        def message(method_name)
          case style
          when :semantic
            method_name == :fail ? RAISE_MSG : FAIL_MSG
          when :only_raise
            'Always use `raise` to signal exceptions.'
          when :only_fail
            'Always use `fail` to signal exceptions.'
          end
        end

        def check_scope(method_name, node)
          return unless node

          each_command_or_kernel_call(method_name, node) do |send_node|
            next if ignored_node?(send_node)

            add_offense(send_node, :selector, message(method_name))
            ignore_node(send_node)
          end
        end

        def check_send(method_name, node)
          return unless node && command_or_kernel_call?(method_name, node)

          add_offense(node, :selector, message(method_name))
        end

        def command_or_kernel_call?(name, node)
          node.command?(name) || kernel_call?(node, name)
        end

        def allow(method_name, node)
          each_command_or_kernel_call(method_name, node) do |send_node|
            ignore_node(send_node)
          end
        end

        def each_command_or_kernel_call(method_name, node)
          on_node(:send, node, :rescue) do |send_node|
            yield send_node if command_or_kernel_call?(method_name, send_node)
          end
        end
      end
    end
  end
end
