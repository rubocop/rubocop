# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for calls to `Kernel#format` or `Kernel#sprintf` with only a single
      # string argument, that can be replaced by the string itself.
      #
      # @example
      #
      #   # bad
      #   format('the quick brown fox jumps over the lazy dog.')
      #   sprintf('the quick brown fox jumps over the lazy dog.')
      #
      #   # good
      #   'the quick brown fox jumps over the lazy dog.'
      #
      class RedundantFormat < Base
        extend AutoCorrector

        MSG = 'Redundant `%<method_name>s` can be removed.'

        RESTRICT_ON_SEND = %i[format sprintf].to_set.freeze

        # @!method format_without_additional_args?(node)
        def_node_matcher :format_without_additional_args?, <<~PATTERN
          (send {(const {nil? cbase} :Kernel) nil?} $%RESTRICT_ON_SEND ${str dstr})
        PATTERN

        def on_send(node)
          format_without_additional_args?(node) do |method_name, value|
            message = format(MSG, method_name: method_name)
            add_offense(node, message: message) do |corrector|
              corrector.replace(node, value.source)
            end
          end
        end
      end
    end
  end
end
