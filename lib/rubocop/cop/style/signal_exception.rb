# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of `fail` and `raise`.
      class SignalException < Cop
        include ConfigurableEnforcedStyle

        FAIL_MSG = 'Use `fail` instead of `raise` to signal exceptions.'
        RAISE_MSG = 'Use `raise` instead of `fail` to rethrow exceptions.'

        def on_rescue(node)
          if style == :semantic
            begin_node, rescue_node = *node

            check_for(:raise, begin_node)
            check_for(:fail, rescue_node)
            allow(:raise, rescue_node)
          end
        end

        def on_send(node)
          case style
          when :semantic
            check_for(:raise, node) unless ignored_node?(node)
          when :only_raise
            check_for(:raise, node)
          when :only_fail
            check_for(:fail, node)
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            name =
              case style
              when :semantic then command?(:raise, node) ? 'fail' : 'raise'
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

        def check_for(method_name, node)
          return unless node

          if style == :semantic
            each_command(method_name, node) do |send_node|
              unless ignored_node?(send_node)
                add_offence(send_node, :selector, message(method_name))
                ignore_node(send_node)
              end
            end
          else
            _receiver, selector, _args = *node

            if [:raise, :fail].include?(selector) && selector != method_name
              add_offence(node, :selector, message(method_name))
            end
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
