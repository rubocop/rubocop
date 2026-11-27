# frozen_string_literal: true

module RuboCop
  module Cop
    class VariableForce
      # The scopes and local variables of a source file, for cops to query:
      #
      #     processed_source.variable_analysis.scopes.each do |scope|
      #       scope.variables.each_value { |variable| ... }
      #     end
      #
      # It is built the first time a cop asks for it and shared by all the cops
      # that inspect the file.
      class Analysis
        # The scopes of the file, in the order the analysis left them, so an
        # inner scope comes before the scope around it.
        #
        # @return [Array<Scope>]
        attr_reader :scopes

        # Each variable that was declared while a variable of the same name was
        # visible from an outer scope, with that outer variable.
        #
        # @return [Array<Array(Variable, Variable)>]
        attr_reader :shadowings

        def initialize(processed_source)
          @scopes = []
          @shadowings = []
          VariableForce.new([self]).investigate(processed_source)
        end

        # @return [Array<Variable>]
        def variables
          @variables ||= scopes.flat_map { |scope| scope.variables.values }
        end

        # Whether the code at the node can see a local variable of the given
        # name: one that is declared in front of the node, in the scope the node
        # is in or in a scope around it that a block lets it see. This is when
        # Ruby reads the bare name as the variable and not as a method call.
        #
        # @param name [Symbol]
        # @param node [RuboCop::AST::Node]
        def variable_visible?(name, node)
          scope_node = node
          while (scope_node = scope_node.parent)
            next unless (scope = scopes_by_node[scope_node])
            return declared_before?(scope.variables[name], node) if scope.variables.key?(name)
            return false unless scope_node.any_block_type?
          end

          false
        end

        # @api private
        def after_leaving_scope(scope, _variable_table)
          @scopes << scope
        end

        # @api private
        def before_declaring_variable(variable, variable_table)
          outer_variable = variable_table.find_variable(variable.name)

          @shadowings << [variable, outer_variable] if outer_variable
        end

        private

        def declared_before?(variable, node)
          variable.declaration_node.source_range.begin_pos < node.source_range.begin_pos
        end

        # A file that is a single definition has two scopes for its root node,
        # and the inner one, which comes first, is the one with the variables.
        def scopes_by_node
          @scopes_by_node ||= scopes.each_with_object({}.compare_by_identity) do |scope, by_node|
            by_node[scope.node] ||= scope
          end
        end
      end
    end
  end
end
