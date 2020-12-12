# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for places where keyword arguments can be used instead of
      # boolean arguments when defining methods. `respond_to_missing?` method is allowed by default.
      # These are customizable with `AllowedMethods` option.
      #
      # @example
      #   # bad
      #   def some_method(bar = false)
      #     puts bar
      #   end
      #
      #   # bad - common hack before keyword args were introduced
      #   def some_method(options = {})
      #     bar = options.fetch(:bar, false)
      #     puts bar
      #   end
      #
      #   # good
      #   def some_method(bar: false)
      #     puts bar
      #   end
      #
      # @example AllowedMethods: ['some_method']
      #   # good
      #   def some_method(bar = false)
      #     puts bar
      #   end
      #
      class OptionalBooleanParameter < Base
        include AllowedMethods
        extend AutoCorrector

        MSG = 'Use keyword arguments when defining method with boolean argument.'
        BOOLEAN_TYPES = %i[true false].freeze

        def on_def(node)
          return if allowed_method?(node.method_name)

          node.arguments.each do |arg|
            next unless arg.optarg_type?

            _name, value = *arg
            next unless BOOLEAN_TYPES.include?(value.type)

            add_offense(arg) do |corrector|
              keyword_argument = "#{arg.name}: #{arg.default_value.source}"

              corrector.replace(arg, keyword_argument)
            end
          end
        end
        alias on_defs on_def
      end
    end
  end
end
