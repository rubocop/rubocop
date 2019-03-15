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
      #   def to_json(_opts)
      #   end
      #
      class ToJSON < Cop
        MSG = ' `#to_json` requires an optional argument to be parsable ' \
          'via JSON.generate(obj).'.freeze

        def on_def(node)
          return unless node.method?(:to_json) && node.arguments.empty?

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.insert_after(node.loc.name, '(_opts)')
          end
        end
      end
    end
  end
end
