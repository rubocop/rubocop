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

          check_for_raise(begin_node)
          check_for_fail(rescue_node)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            name = command?(:raise, node) ? 'fail' : 'raise'
            corrector.replace(node.loc.selector, name)
          end
        end

        private

        def check_for_raise(node)
          return unless node

          on_node(:send, node, :rescue) do |send_node|
            if command?(:raise, send_node)
              convention(send_node, :selector, FAIL_MSG)
            end
          end
        end

        def check_for_fail(node)
          return unless node

          on_node(:send, node, :rescue) do |send_node|
            if command?(:fail, send_node)
              convention(send_node, :selector, RAISE_MSG)
            end
          end
        end
      end
    end
  end
end
