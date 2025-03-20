# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # All values in ENV are strings (or objects responding to #to_str).
      # Always use strings as default values for ENV.fetch
      #
      # @example
      #
      #   # bad
      #   ENV.fetch("some_key", 0)
      #
      #   # good
      #   ENV.fetch("some_key", "0")
      #   ENV.fetch("some_key", a) # allows non-literals
      #
      class EnvFetchStringDefault < Base
        MSG = 'Use a string as default value for ENV.fetch.'

        RESTRICT_ON_SEND = %i[fetch].freeze

        # @!method env_fetch(node)
        def_node_matcher :env_fetch, <<~PATTERN
          (send (const nil? :ENV) :fetch _ $_)
        PATTERN

        def on_send(node)
          env_fetch(node) do |default_value|
            if default_value.basic_literal? && !default_value.type?(:str, :nil)
              add_offense(default_value)
            end
          end
        end
        alias on_csend on_send
      end
    end
  end
end
