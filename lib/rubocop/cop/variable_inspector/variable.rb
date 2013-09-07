# encoding: utf-8

module Rubocop
  module Cop
    module VariableInspector
      # A Variable represents existance of a local variable.
      # This holds a variable declaration node,
      # and some states of the variable.
      class Variable
        VARIABLE_DECLARATION_TYPES =
          (VARIABLE_ASSIGNMENT_TYPES + ARGUMENT_DECLARATION_TYPES).freeze

        attr_reader :node
        attr_accessor :used
        alias_method :used?, :used

        def initialize(node, name = nil)
          unless VARIABLE_DECLARATION_TYPES.include?(node.type)
            fail ArgumentError,
                 "Node type must be any of #{VARIABLE_DECLARATION_TYPES}, " +
                 "passed #{node.type}"
          end
          @node = node
          @name = name.to_sym if name
          @used = false
        end

        def name
          @name || @node.children.first
        end
      end
    end
  end
end
