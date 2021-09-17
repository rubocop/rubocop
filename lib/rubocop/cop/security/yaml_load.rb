# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # This cop checks for the use of YAML class methods which have
      # potential security issues leading to remote code execution when
      # loading from an untrusted source.
      #
      # @safety
      #   The behaviour of the code might change depending on what was
      #   in the YAML payload, since `YAML.safe_load` is more restrictive.
      #
      # @example
      #   # bad
      #   YAML.load("--- foo")
      #
      #   # good
      #   YAML.safe_load("--- foo")
      #   YAML.dump("foo")
      #
      class YAMLLoad < Base
        extend AutoCorrector

        MSG = 'Prefer using `YAML.safe_load` over `YAML.load`.'
        RESTRICT_ON_SEND = %i[load].freeze

        # @!method yaml_load(node)
        def_node_matcher :yaml_load, <<~PATTERN
          (send (const {nil? cbase} :YAML) :load ...)
        PATTERN

        def on_send(node)
          yaml_load(node) do
            add_offense(node.loc.selector) do |corrector|
              corrector.replace(node.loc.selector, 'safe_load')
            end
          end
        end
      end
    end
  end
end
