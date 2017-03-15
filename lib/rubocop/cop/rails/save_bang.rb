# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop identifies possible cases where Active Record save! or related
      # should be used instead of save because the model might have failed to
      # save and an exception is better than unhandled failure.
      #
      # This will ignore calls that return a boolean for success if the result
      # is assigned to a variable or used as the condition in an if/unless
      # statement.  It will also ignore calls that return a model assigned to a
      # variable that has a call to `persisted?`. Finally, it will ignore any
      # call with more than 2 arguments as that is likely not an Active Record
      # call or a Model.update(id, attributes) call.
      #
      # @example
      #
      #   # bad
      #   user.save
      #   user.update(name: 'Joe')
      #   user.find_or_create_by(name: 'Joe')
      #   user.destroy
      #
      #   # good
      #   unless user.save
      #      . . .
      #   end
      #   user.save!
      #   user.update!(name: 'Joe')
      #   user.find_or_create_by!(name: 'Joe')
      #   user.destroy!
      #
      #   user = User.find_or_create_by(name: 'Joe')
      #   unless user.persisted?
      #      . . .
      #   end
      class SaveBang < Cop
        MSG = 'Use `%s` instead of `%s` if the return value is not checked.'
              .freeze
        CREATE_MSG = (MSG +
                      ' Or check `persisted?` on model returned from `%s`.')
                     .freeze
        CREATE_CONDITIONAL_MSG = '`%s` returns a model which is always truthy.'
                                 .freeze

        CREATE_PERSIST_METHODS = [:create,
                                  :first_or_create, :find_or_create_by].freeze
        MODIFY_PERSIST_METHODS = [:save,
                                  :update, :update_attributes, :destroy].freeze
        PERSIST_METHODS = (CREATE_PERSIST_METHODS +
                           MODIFY_PERSIST_METHODS).freeze

        def join_force?(force_class)
          force_class == VariableForce
        end

        def after_leaving_scope(scope, _variable_table)
          scope.variables.each do |_name, variable|
            variable.assignments.each do |assignment|
              check_assignment(assignment)
            end
          end
        end

        def check_assignment(assignment)
          node = right_assignment_node(assignment)
          return unless node
          return unless CREATE_PERSIST_METHODS.include?(node.method_name)
          return unless expected_signature?(node)
          return if persisted_referenced?(assignment)

          add_offense(node, node.loc.selector,
                      format(CREATE_MSG,
                             "#{node.method_name}!",
                             node.method_name.to_s,
                             node.method_name.to_s))
        end

        def on_send(node)
          return unless PERSIST_METHODS.include?(node.method_name)
          return unless expected_signature?(node)
          return if return_value_assigned?(node)
          return if check_used_in_conditional(node)
          return if last_call_of_method?(node)

          add_offense(node, node.loc.selector,
                      format(MSG,
                             "#{node.method_name}!",
                             node.method_name.to_s))
        end

        def autocorrect(node)
          save_loc = node.loc.selector
          new_method = "#{node.method_name}!"

          ->(corrector) { corrector.replace(save_loc, new_method) }
        end

        private

        def right_assignment_node(assignment)
          node = assignment.node.child_nodes.first
          return node unless node && node.block_type?
          node.child_nodes.first
        end

        def persisted_referenced?(assignment)
          return unless assignment.referenced?
          assignment.variable.references.any? do |reference|
            reference.node.parent.method?(:persisted?)
          end
        end

        def check_used_in_conditional(node)
          return false unless conditional?(node)

          unless MODIFY_PERSIST_METHODS.include?(node.method_name)
            add_offense(node, node.loc.selector,
                        format(CREATE_CONDITIONAL_MSG,
                               node.method_name.to_s))
          end

          true
        end

        def conditional?(node)
          node.parent && (node.parent.if_type? && node.sibling_index.zero? ||
            conditional?(node.parent))
        end

        def last_call_of_method?(node)
          node.parent && node.parent.children.count == node.sibling_index + 1
        end

        # Ignore simple assignment or if condition
        def return_value_assigned?(node)
          return false unless node.parent
          node.parent.lvasgn_type? ||
            (node.parent.block_type? && node.parent.parent &&
              node.parent.parent.lvasgn_type?)
        end

        # Check argument signature as no arguments or one hash
        def expected_signature?(node)
          !node.arguments? ||
            (node.arguments.one? &&
              node.method_name != :destroy &&
              (node.first_argument.hash_type? ||
              !node.first_argument.literal?))
        end
      end
    end
  end
end
