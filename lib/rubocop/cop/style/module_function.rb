# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks for use of `extend self` in a module.
      #
      # @example
      #
      #   module Test
      #     extend self
      #
      #     ...
      # end
      class ModuleFunction < Cop
        MSG = 'Use `module_function` instead of `extend self`.'.freeze

        TARGET_NODE = s(:send, nil, :extend, s(:self))

        def on_module(node)
          _name, body = *node
          return unless body && body.type == :begin

          body.children.each do |body_node|
            add_offense(body_node, :expression) if body_node == TARGET_NODE
          end
        end
      end
    end
  end
end
