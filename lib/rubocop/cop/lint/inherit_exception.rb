# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop looks for error classes inheriting from `Exception`
      # and its standard library subclasses, excluding subclasses of
      # `StandardError`. It is configurable to suggest using either
      # `RuntimeError` (default) or `StandardError` instead.
      #
      # @example EnforcedStyle: runtime_error (default)
      #   # bad
      #
      #   class C < Exception; end
      #
      #   C = Class.new(Exception)
      #
      #   # good
      #
      #   class C < RuntimeError; end
      #
      #   C = Class.new(RuntimeError)
      #
      # @example EnforcedStyle: standard_error
      #   # bad
      #
      #   class C < Exception; end
      #
      #   C = Class.new(Exception)
      #
      #   # good
      #
      #   class C < StandardError; end
      #
      #   C = Class.new(StandardError)
      class InheritException < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Inherit from `%<prefer>s` instead of `%<current>s`.'
        PREFERRED_BASE_CLASS = {
          runtime_error: 'RuntimeError',
          standard_error: 'StandardError'
        }.freeze
        ILLEGAL_CLASSES = %w[
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
        ].freeze

        def_node_matcher :class_new_call?, <<~PATTERN
          (send
            (const {cbase nil?} :Class) :new
            $(const {cbase nil?} _))
        PATTERN

        def on_class(node)
          return unless node.parent_class &&
                        illegal_class_name?(node.parent_class)

          add_offense(node.parent_class)
        end

        def on_send(node)
          constant = class_new_call?(node)
          return unless constant && illegal_class_name?(constant)

          add_offense(constant)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, preferred_base_class)
          end
        end

        private

        def message(node)
          format(MSG, prefer: preferred_base_class, current: node.const_name)
        end

        def illegal_class_name?(class_node)
          ILLEGAL_CLASSES.include?(class_node.const_name)
        end

        def preferred_base_class
          PREFERRED_BASE_CLASS[style]
        end
      end
    end
  end
end
