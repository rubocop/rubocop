# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for every useless assignment to local variable in every
      # scope.
      # The basic idea for this cop was from the warning of `ruby -cw`:
      #
      #   assigned but unused variable - foo
      #
      # Currently this cop has advanced logic that detects unreferenced
      # reassignments and properly handles varied cases such as branch, loop,
      # rescue, ensure, etc.
      class UselessAssignment < Cop
        include NameSimilarity
        MSG = 'Useless assignment to variable - `%s`.'.freeze

        def join_force?(force_class)
          force_class == VariableForce
        end

        def after_leaving_scope(scope, _variable_table)
          scope.variables.each_value do |variable|
            check_for_unused_assignments(variable)
          end
        end

        def check_for_unused_assignments(variable)
          return if variable.should_be_unused?

          variable.assignments.each do |assignment|
            next if assignment.used?

            message = message_for_useless_assignment(assignment)

            location = if assignment.regexp_named_capture?
                         assignment.node.children.first.source_range
                       else
                         assignment.node.loc.name
                       end

            add_offense(nil, location, message)
          end
        end

        def message_for_useless_assignment(assignment)
          variable = assignment.variable

          message = format(MSG, variable.name)

          if assignment.multiple_assignment?
            message << " Use `_` or `_#{variable.name}` as a variable name " \
                       "to indicate that it won't be used."
          elsif assignment.operator_assignment?
            return_value_node = return_value_node_of_scope(variable.scope)
            if assignment.meta_assignment_node.equal?(return_value_node)
              non_assignment_operator = assignment.operator.sub(/=$/, '')
              message << " Use just operator `#{non_assignment_operator}`."
            end
          else
            similar_name = find_similar_name(variable.name, variable.scope)
            message << " Did you mean `#{similar_name}`?" if similar_name
          end

          message
        end

        # TODO: More precise handling (rescue, ensure, nested begin, etc.)
        def return_value_node_of_scope(scope)
          body_node = scope.body_node

          if body_node.type == :begin
            body_node.children.last
          else
            body_node
          end
        end

        def collect_variable_like_names(scope)
          names = scope.each_node.with_object(Set.new) do |node, set|
            if variable_like_method_invocation?(node)
              _receiver, method_name, = *node
              set << method_name
            end
          end

          variable_names = scope.variables.each_value.map(&:name)
          names.merge(variable_names)
        end

        def variable_like_method_invocation?(node)
          return false unless node.send_type?
          receiver, _method_name, *args = *node
          receiver.nil? && args.empty?
        end
      end
    end
  end
end
