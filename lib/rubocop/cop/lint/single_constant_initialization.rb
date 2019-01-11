# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks that there are no constants initialized more than once.
      #
      # @example
      #
      #   # bad
      #
      #   CONSTANT = 1
      #   CONSTANT = 2
      #
      # @example
      #
      #   # good
      #
      #   CONSTANT = 1
      #
      class SingleConstantInitialization < Cop
        MSG = 'Constant `%<constant_name>s` initialized more than once.'.freeze

        def initialize(config = nil, options = nil)
          super
          @initializations = {}
        end

        def on_casgn(node)
          constant_name = node.children[1]
          constant_id = [*scope(node), constant_name].join('::')

          already_initialized = @initializations[constant_id]

          if already_initialized
            message = format(MSG, constant_name: constant_name)
            add_offense(node, message: message)
          else
            @initializations[constant_id] = true
          end
        end

        private

        def_node_matcher :class?, <<-PATTERN
          (class (const nil? $_name) ...)
        PATTERN

        def_node_matcher :module?, <<-PATTERN
          (module (const nil? $_name) ...)
        PATTERN

        def scope(node, scope = [])
          return scope if node.parent.nil?

          if (name = (class?(node) || module?(node)))
            scope.unshift(name)
          end

          scope(node.parent, scope)
        end
      end
    end
  end
end
