# encoding: utf-8

module Rubocop
  module Cop
    module VariableInspector
      # This class represents each reference of a variable.
      class Reference
        include Locatable

        attr_reader :node, :scope

        def initialize(node, scope)
          # unless VARIABLE_ASSIGNMENT_TYPES.include?(node.type)
          #   fail ArgumentError,
          #        "Node type must be any of #{VARIABLE_ASSIGNMENT_TYPES}, " +
          #        "passed #{node.type}"
          # end

          @node = node
          @scope = scope
        end
      end
    end
  end
end
