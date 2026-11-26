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

        # @api private
        def after_leaving_scope(scope, _variable_table)
          @scopes << scope
        end

        # @api private
        def before_declaring_variable(variable, variable_table)
          outer_variable = variable_table.find_variable(variable.name)

          @shadowings << [variable, outer_variable] if outer_variable
        end
      end
    end
  end
end
