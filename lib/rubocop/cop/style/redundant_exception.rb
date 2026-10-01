# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `RuntimeError` as the argument of `raise`/`fail`.
      #
      # @example
      #   # bad
      #   raise RuntimeError, 'message'
      #   raise RuntimeError.new('message')
      #
      #   # good
      #   raise 'message'
      #
      #   # bad - message is not a string
      #   raise RuntimeError, Object.new
      #   raise RuntimeError.new(Object.new)
      #
      #   # good
      #   raise Object.new.to_s
      #
      class RedundantException < Base
        extend AutoCorrector

        MSG_1 = 'Redundant `RuntimeError` argument can be removed.'
        MSG_2 = 'Redundant `RuntimeError.new` call can be replaced with just the message.'

        RESTRICT_ON_SEND = %i[raise fail].freeze

        # Switch `raise RuntimeError, 'message'` to `raise 'message'`, and
        # `raise RuntimeError.new('message')` to `raise 'message'`.
        def on_send(node)
          fix_exploded(node) || fix_compact(node)
        end

        private

        def fix_exploded(node)
          exploded?(node) do |command, message|
            # `raise RuntimeError, nil` uses the class name as the message, so
            # rewriting it to `raise nil.to_s` (an empty message) would change it.
            next if message.nil_type?

            add_offense(node, message: MSG_1) do |corrector|
              corrector.replace(node, replaced_exploded(node, command, message))
            end
          end
        end

        def replaced_exploded(node, command, message)
          arg = message_source(message)
          arg = node.parenthesized? ? "(#{arg})" : " #{arg}"
          "#{command}#{arg}"
        end

        def string_message?(message)
          message.any_str_type?
        end

        def fix_compact(node)
          compact?(node) do |new_call, message|
            next if message.nil_type?

            add_offense(node, message: MSG_2) do |corrector|
              corrector.replace(new_call, message_source(message))
            end
          end
        end

        def message_source(message)
          if string_message?(message)
            message.source
          elsif require_parentheses?(message)
            "(#{message.source}).to_s"
          else
            "#{message.source}.to_s"
          end
        end

        def require_parentheses?(message)
          if message.call_type?
            !message.method?(:[]) &&
              (message.operator_method? || (message.arguments? && !message.parenthesized?))
          else
            !(message.basic_literal? || message.variable? ||
              message.type?(:const, :self, :begin, :array))
          end
        end

        # @!method exploded?(node)
        def_node_matcher :exploded?, <<~PATTERN
          (send nil? ${:raise :fail} (const {nil? cbase} :RuntimeError) $_)
        PATTERN

        # @!method compact?(node)
        def_node_matcher :compact?, <<~PATTERN
          (send nil? {:raise :fail} $(send (const {nil? cbase} :RuntimeError) :new $_))
        PATTERN
      end
    end
  end
end
