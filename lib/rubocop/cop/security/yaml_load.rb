# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # This cop checks for the use of YAML class methods which have
      # potential security issues leading to remote code execution when
      # loading from an untrusted source.
      #
      # @example
      #   # bad
      #   YAML.load("--- foo")
      #
      #   # good
      #   YAML.safe_load("--- foo")
      #   YAML.dump("foo")
      #
      class YAMLLoad < Cop
        MSG = 'Prefer using `YAML.safe_load` over `YAML.load`.'.freeze

        def_node_matcher :yaml_load, <<-END
          (send (const {nil cbase} :YAML) :load ...)
        END

        def on_send(node)
          yaml_load(node) do
            add_offense(node, :selector)
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'safe_load') }
        end
      end
    end
  end
end
