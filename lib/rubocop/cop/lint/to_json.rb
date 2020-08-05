# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks to make sure `#to_json` includes an optional argument.
      # When overriding `#to_json`, callers may invoke JSON
      # generation via `JSON.generate(your_obj)`.  Since `JSON#generate` allows
      # for an optional argument, your method should too.
      #
      # @example
      #   # bad
      #   def to_json
      #   end
      #
      #   # good
      #   def to_json(*_args)
      #   end
      #
      class ToJSON < Base
        extend AutoCorrector

        MSG = ' `#to_json` requires an optional argument to be parsable ' \
          'via JSON.generate(obj).'

        def on_def(node)
          return unless node.method?(:to_json) && node.arguments.empty?

          add_offense(node) do |corrector|
            # The following used `*_args` because `to_json(*args)` has
            # an offense of `Lint/UnusedMethodArgument` cop if `*args`
            # is not used.
            corrector.insert_after(node.loc.name, '(*_args)')
          end
        end
      end
    end
  end
end
