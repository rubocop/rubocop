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
      class RedundantException < Cop
        MSG_1 = 'Redundant `RuntimeError` argument can be removed.'.freeze
        MSG_2 = 'Redundant `RuntimeError.new` call can be replaced with ' \
                'just the message.'.freeze

        def on_send(node)
          exploded?(node) { return add_offense(node, :expression, MSG_1) }
          compact?(node) { add_offense(node, :expression, MSG_2) }
        end

        # Switch `raise RuntimeError, 'message'` to `raise 'message'`, and
        # `raise RuntimeError.new('message')` to `raise 'message'`.
        def autocorrect(node)
          exploded?(node) do |command, message|
            return lambda do |corrector|
              corrector.replace(node.source_range,
                                "#{command} #{message.source}")
            end
          end
          compact?(node) do |new_call, message|
            lambda do |corrector|
              corrector.replace(new_call.source_range, message.source)
            end
          end
        end

        def_node_matcher :exploded?, <<-PATTERN
          (send nil ${:raise :fail} (const nil :RuntimeError) $_)
        PATTERN

        def_node_matcher :compact?, <<-PATTERN
          (send nil {:raise :fail} $(send (const nil :RuntimeError) :new $_))
        PATTERN
      end
    end
  end
end
