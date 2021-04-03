# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for RuntimeError as the argument of raise/fail.
      #
      # It checks for code like this:
      #
      # @example
      #   # Bad
      #   raise RuntimeError, 'message'
      #
      #   # Bad
      #   raise RuntimeError.new('message')
      #
      #   # Good
      #   raise 'message'
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

        def fix_exploded(node)
          exploded?(node) do |command, message|
            add_offense(node, message: MSG_1) do |corrector|
              if node.parenthesized?
                corrector.replace(node, "#{command}(#{message.source})")
              else
                corrector.replace(node, "#{command} #{message.source}")
              end
            end
          end
        end

        def fix_compact(node)
          compact?(node) do |new_call, message|
            add_offense(node, message: MSG_2) do |corrector|
              corrector.replace(new_call, message.source)
            end
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
