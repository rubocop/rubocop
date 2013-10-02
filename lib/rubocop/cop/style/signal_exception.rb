# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of `fail` and `raise`.
      class SignalException < Cop
        FAIL_MSG = 'Use `fail` instead of `raise` to signal exceptions.'
        RAISE_MSG = 'Use `raise` instead of `fail` to rethrow exceptions.'

        def on_rescue(node)
          begin_node, rescue_node = *node

          check_for(:raise, begin_node)
          check_for(:fail, rescue_node)
          allow(:raise, rescue_node)
        end

        def on_send(node)
          check_for(:raise, node) unless ignored_node?(node)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            name = command?(:raise, node) ? 'fail' : 'raise'
            corrector.replace(node.loc.selector, name)
          end
        end

        private

        def check_for(method_name, node)
          return unless node

          each_command(method_name, node) do |send_node|
            msg = method_name == :fail ? RAISE_MSG : FAIL_MSG
            convention(send_node, :selector, msg)
            ignore_node(send_node)
          end
        end

        def allow(method_name, node)
          each_command(method_name, node) do |send_node|
            ignore_node(send_node)
          end
        end

        def each_command(method_name, node)
          on_node(:send, node, :rescue) do |send_node|
            yield send_node if command?(method_name, send_node)
          end
        end
      end
    end
  end
end
