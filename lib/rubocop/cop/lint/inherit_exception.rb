# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop looks for error classes inheriting from `Exception`.
      # It is configurable to suggest using either `RuntimeError` (default) or
      # `StandardError` instead.
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

        MSG = 'Inherit from `%s` instead of `Exception`.'.freeze
        PREFERRED_BASE_CLASS = {
          runtime_error: 'RuntimeError',
          standard_error: 'StandardError'
        }.freeze

        def on_class(node)
          _class, base_class, _body = *node

          return if base_class.nil?

          check(base_class)
        end

        private

        def check(node)
          return unless node.const_name == 'Exception'

          add_offense(node, :expression, format(MSG, preferred_base_class))
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
