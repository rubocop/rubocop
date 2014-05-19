# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for use of `extend self` in a module.
      #
      # @example
      #
      # module Test
      #   extend self
      #
      #   ...
      # end
      class ModuleFunction < Cop
        MSG = 'Use `module_function` instead of `extend self`.'
        TARGET_NODE = s(:send, nil, :extend, s(:self))
        private_constant :MSG, :TARGET_NODE

        def on_module(node)
          _name, body = *node
          return unless body && body.type == :begin

          body.children.each do |body_node|
            next unless body_node == TARGET_NODE
            add_offense(body_node, :expression, MSG)
          end
        end
      end
    end
  end
end
