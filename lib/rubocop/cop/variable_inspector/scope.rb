# encoding: utf-8

module Rubocop
  module Cop
    module VariableInspector
      # A Scope represents a context of local variable visibility.
      # This is a place where local variables belong to.
      # A scope instance holds a scope node and variable entries.
      class Scope
        attr_reader :node, :variables

        def initialize(node)
          # Accept begin node for top level scope.
          unless SCOPE_TYPES.include?(node.type) || node.type == :begin
            fail ArgumentError,
                 "Node type must be any of #{SCOPE_TYPES}, " +
                 "passed #{node.type}"
          end
          @node = node
          @variables = {}
        end
      end
    end
  end
end
