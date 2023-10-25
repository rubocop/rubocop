# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Avoids having both `JSON.generate` and `Object#to_json` in your codebase.
      # They are equivalent, so for simplicity it makes sense to use only one.
      # `to_json` is also what ActiveModel::Serializer uses, to it's easier to standardize on it.
      #
      # @example
      #   # bad
      #   JSON.generate(something)
      #
      #   # good
      #   something.to_json
      class ToJson < Base
        extend AutoCorrector

        MSG = 'Use `.to_json` instead of `JSON.generate`.'

        # @!method json_generate?(node)
        def_node_matcher :json_generate?, <<~PATTERN
          (send (const {nil? cbase} :JSON) :generate
            $_object
            $_options ?
          )
        PATTERN

        def on_send(node)
          json_generate?(node) do |object, maybe_options|
            add_offense(node) do |corrector|
              receiver = braceless_hash?(object) ? "{ #{object.source} }" : object.source
              replacement = "#{receiver}.to_json"
              if (options = maybe_options.first)
                replacement += "(#{options.source})"
              end
              corrector.replace(node, replacement)
            end
          end
        end

        private

        def braceless_hash?(node)
          node.hash_type? && !node.braces?
        end
      end
    end
  end
end
