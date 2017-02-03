# frozen_string_literal: true

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
      #
      # @example
      #
      #   # bad
      #
      #   def some_method
      #     some_var = 1
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method
      #     some_var = 1
      #     do_something(some_var)
      #   end
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

          format(MSG, variable.name) +
            message_specification(assignment, variable).to_s
        end

        def message_specification(assignment, variable)
          if assignment.multiple_assignment?
            multiple_assignment_message(variable.name)
          elsif assignment.operator_assignment?
            operator_assignment_message(variable.scope, assignment)
          else
            similar_name_message(variable)
          end
        end

        def multiple_assignment_message(variable_name)
          " Use `_` or `_#{variable_name}` as a variable name to indicate " \
            "that it won't be used."
        end

        def operator_assignment_message(scope, assignment)
          return_value_node = return_value_node_of_scope(scope)
          return unless assignment.meta_assignment_node
                                  .equal?(return_value_node)

          " Use `#{assignment.operator.sub(/=$/, '')}` instead of `#{assignment.operator}`."
        end

        def similar_name_message(variable)
          similar_name = find_similar_name(variable.name, variable.scope)
          " Did you mean `#{similar_name}`?" if similar_name
        end

        # TODO: More precise handling (rescue, ensure, nested begin, etc.)
        def return_value_node_of_scope(scope)
          body_node = scope.body_node

          if body_node.begin_type?
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
