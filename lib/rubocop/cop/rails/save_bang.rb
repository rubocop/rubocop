# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop identifies possible cases where Active Record save! or related
      # should be used instead of save because the model might have failed to
      # save and an exception is better than unhandled failure.
      #
      # This will allow:
      # - update or save calls, assigned to a variable,
      #   or used as a condition in an if/unless/case statement.
      # - create calls, assigned to a variable that then has a
      #   call to `persisted?`.
      # - calls if the result is explicitly returned from methods and blocks,
      #   or provided as arguments.
      # - calls whose signature doesn't look like an ActiveRecord
      #   persistence method.
      #
      # By default it will also allow implicit returns from methods and blocks.
      # that behavior can be turned off with `AllowImplicitReturn: false`.
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
      #     # ...
      #   end
      #   user.save!
      #   user.update!(name: 'Joe')
      #   user.find_or_create_by!(name: 'Joe')
      #   user.destroy!
      #
      #   user = User.find_or_create_by(name: 'Joe')
      #   unless user.persisted?
      #     # ...
      #   end
      #
      #   def save_user
      #     return user.save
      #   end
      #
      # @example AllowImplicitReturn: true (default)
      #
      #   # good
      #   users.each { |u| u.save }
      #
      #   def save_user
      #     user.save
      #   end
      #
      # @example AllowImplicitReturn: false
      #
      #   # bad
      #   users.each { |u| u.save }
      #   def save_user
      #     user.save
      #   end
      #
      #   # good
      #   users.each { |u| u.save! }
      #
      #   def save_user
      #     user.save!
      #   end
      #
      #   def save_user
      #     return user.save
      #   end
      class SaveBang < Cop
        include NegativeConditional

        MSG = 'Use `%<prefer>s` instead of `%<current>s` if the return ' \
              'value is not checked.'.freeze
        CREATE_MSG = (MSG +
                      ' Or check `persisted?` on model returned from ' \
                      '`%<current>s`.').freeze
        CREATE_CONDITIONAL_MSG = '`%<method>s` returns a model which is ' \
                                 'always truthy.'.freeze

        CREATE_PERSIST_METHODS = %i[create
                                    first_or_create find_or_create_by].freeze
        MODIFY_PERSIST_METHODS = %i[save
                                    update update_attributes destroy].freeze
        PERSIST_METHODS = (CREATE_PERSIST_METHODS +
                           MODIFY_PERSIST_METHODS).freeze

        def join_force?(force_class)
          force_class == VariableForce
        end

        def after_leaving_scope(scope, _variable_table)
          scope.variables.each_value do |variable|
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

          add_offense(node, location: :selector,
                            message: format(CREATE_MSG,
                                            prefer: "#{node.method_name}!",
                                            current: node.method_name.to_s))
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def on_send(node)
          return unless PERSIST_METHODS.include?(node.method_name)
          return unless expected_signature?(node)
          return if return_value_assigned?(node)
          return if check_used_in_conditional(node)
          return if argument?(node)
          return if implicit_return?(node)
          return if explicit_return?(node)

          add_offense(node, location: :selector,
                            message: format(MSG,
                                            prefer: "#{node.method_name}!",
                                            current: node.method_name.to_s))
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity

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
            call_to_persisted?(reference.node.parent)
          end
        end

        def call_to_persisted?(node)
          node.send_type? && node.method?(:persisted?)
        end

        def check_used_in_conditional(node)
          return false unless conditional?(node)

          unless MODIFY_PERSIST_METHODS.include?(node.method_name)
            add_offense(node, location: :selector,
                              message: format(CREATE_CONDITIONAL_MSG,
                                              method: node.method_name.to_s))
          end

          true
        end

        def conditional?(node)
          node.parent && (
            node.parent.if_type? || node.parent.case_type? ||
            node.parent.or_type? || node.parent.and_type? ||
            single_negative?(node.parent)
          )
        end

        def implicit_return?(node)
          return false unless cop_config['AllowImplicitReturn']
          node.parent &&
            (node.parent.def_type? || node.parent.block_type?) &&
            node.parent.children.size == node.sibling_index + 1
        end

        def argument?(node)
          # positional argument
          return true if node.argument?
          # keyword argument
          node.parent && node.parent.parent &&
            node.parent.parent.hash_type? &&
            node.parent.parent.argument?
        end

        def explicit_return?(node)
          node.parent &&
            (node.parent.return_type? || node.parent.next_type?)
        end

        # Ignore simple assignment or if condition
        def return_value_assigned?(node)
          return false unless node.parent
          node.parent.lvasgn_type? ||
            return_block_value_assigned?(node) ||
            return_hash_value_assigned?(node)
        end

        def return_block_value_assigned?(node)
          node.parent &&
            node.parent.block_type? &&
            node.parent.parent &&
            node.parent.parent.lvasgn_type?
        end

        def return_hash_value_assigned?(node)
          node.parent &&
            node.parent.parent &&
            node.parent.parent.hash_type? &&
            node.parent.parent.parent &&
            node.parent.parent.parent.lvasgn_type?
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
