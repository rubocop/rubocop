# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # This cop checks for the use of Marshal class methods which have
      # potential security issues leading to remote code execution when
      # loading from an untrusted source.
      #
      # @example
      #   # bad
      #   Marshal.load("{}")
      #   Marshal.restore("{}")
      #
      #   # good
      #   Marshal.dump("{}")
      #
      #   # okish - deep copy hack
      #   Marshal.load(Marshal.dump({}))
      #
      class MarshalLoad < Cop
        MSG = 'Avoid using `Marshal.%s`.'.freeze

        def_node_matcher :marshal_load, <<-PATTERN
          (send (const {nil? cbase} :Marshal) ${:load :restore}
          !(send (const {nil? cbase} :Marshal) :dump ...))
        PATTERN

        def on_send(node)
          marshal_load(node) do |method|
            add_offense(node, :selector, format(MSG, method))
          end
        end
      end
    end
  end
end
