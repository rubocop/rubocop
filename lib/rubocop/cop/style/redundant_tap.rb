# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of `Object#tap` where the block only invokes a method
      # that returns the receiver.
      #
      # `Object#tap` always returns the receiver, so wrapping a single call to
      # such a method is redundant.
      #
      # @safety
      #   This cop is unsafe because it cannot be guaranteed that the receiver's
      #   implementation of the invoked method returns the receiver.
      #
      # @example
      #   # bad
      #   obj.tap(&:freeze)
      #   obj.tap { |x| x.freeze }
      #
      #   # good
      #   obj.freeze
      #
      # @example MethodsReturningSelf: ['freeze', 'force_encoding']
      #   # bad
      #   str.tap { |s| s.force_encoding('UTF-8') }
      #
      #   # good
      #   str.force_encoding('UTF-8')
      #
      class RedundantTap < Base
        extend AutoCorrector

        MSG = 'Use `#%<method>s` directly instead of `#tap`.'

        RESTRICT_ON_SEND = %i[tap].to_set.freeze

        # @!method tap_with_symbol_proc?(node)
        def_node_matcher :tap_with_symbol_proc?, <<~PATTERN
          (call $_ :tap (block_pass (sym $_method)))
        PATTERN

        # @!method tap_with_block?(node)
        def_node_matcher :tap_with_block?, <<~PATTERN
          (any_block
            $(call _ :tap)
            _
            (send (lvar _) $_method ...))
        PATTERN

        def on_send(node)
          tap_with_symbol_proc?(node) do |receiver, method_name|
            next unless method_returning_self?(method_name)

            register_offense(node, receiver, node, method_name)
          end
        end
        alias on_csend on_send

        def on_block(node)
          tap_with_block?(node) do |send_node, method_name|
            next unless method_returning_self?(method_name)

            register_offense(node, send_node.receiver, send_node, method_name, node.body)
          end
        end
        alias on_numblock on_block
        alias on_itblock on_block

        private

        def register_offense(node, receiver, send_node, method_name, body_node = nil)
          message = format(MSG, method: method_name)

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, correction(receiver, send_node, method_name, body_node))
          end
        end

        def correction(receiver, send_node, method_name, body_node)
          method_call = if body_node
                          args_source = body_node.arguments.map(&:source).join(', ')
                          args_part = args_source.empty? ? '' : "(#{args_source})"
                          "#{method_name}#{args_part}"
                        else
                          method_name.to_s
                        end

          "#{receiver.source}#{navigation(send_node)}#{method_call}"
        end

        def method_returning_self?(method_name)
          methods_returning_self.include?(method_name.to_s)
        end

        def methods_returning_self
          @methods_returning_self ||= Array(cop_config.fetch('MethodsReturningSelf', ['freeze']))
        end

        def navigation(send_node)
          send_node.csend_type? ? '&.' : '.'
        end
      end
    end
  end
end
