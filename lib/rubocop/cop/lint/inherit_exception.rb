# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop looks for error classes inheriting from `Exception`
      # and its standard library subclasses, excluding subclasses of
      # `StandardError`. It is configurable to suggest using either
      # `RuntimeError` (default) or `StandardError` instead.
      #
      # @example
      #
      #   # bad
      #
      #   class C < Exception; end
      #
      # @example
      #
      #   # EnforcedStyle: runtime_error (default)
      #
      #   # good
      #
      #   class C < RuntimeError; end
      #
      # @example
      #
      #   # EnforcedStyle: standard_error
      #
      #   # good
      #
      #   class C < StandardError; end
      class InheritException < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Inherit from `%s` instead of `%s`.'.freeze
        PREFERRED_BASE_CLASS = {
          runtime_error: 'RuntimeError',
          standard_error: 'StandardError'
        }.freeze
        ILLEGAL_CLASSES = %w(
          Exception
          SystemStackError
          NoMemoryError
          SecurityError
          NotImplementedError
          LoadError
          SyntaxError
          ScriptError
          Interrupt
          SignalException
          SystemExit
        ).freeze

        def on_class(node)
          _class, base_class, _body = *node

          return if base_class.nil?

          check(base_class)
        end

        private

        def check(node)
          return unless ILLEGAL_CLASSES.include?(node.const_name)

          msg = format(MSG, preferred_base_class, node.const_name)
          add_offense(node, :expression, msg)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, preferred_base_class)
          end
        end

        def preferred_base_class
          PREFERRED_BASE_CLASS[style]
        end
      end
    end
  end
end
