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

        def on_module(node)
          _name, body = *node

          if body && body.type == :begin
            body.children.each do |body_node|
              add_offence(body_node, :expression) if body_node == TARGET_NODE
            end
          end
        end
      end
    end
  end
end
