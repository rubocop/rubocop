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
      # You can permit receivers that are giving false positives with
      # `AllowedReceivers: []`
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
      #
      # @example AllowedReceivers: ['merchant.customers', 'Service::Mailer']
      #
      #   # bad
      #   merchant.create
      #   customers.builder.save
      #   Mailer.create
      #
      #   module Service::Mailer
      #     self.create
      #   end
      #
      #   # good
      #   merchant.customers.create
      #   MerchantService.merchant.customers.destroy
      #   Service::Mailer.update(message: 'Message')
      #   ::Service::Mailer.update
      #   Services::Service::Mailer.update(message: 'Message')
      #   Service::Mailer::update
      #
      class SaveBang < Cop
        include NegativeConditional

        MSG = 'Use `%<prefer>s` instead of `%<current>s` if the return ' \
              'value is not checked.'
        CREATE_MSG = (MSG +
                      ' Or check `persisted?` on model returned from ' \
                      '`%<current>s`.').freeze
        CREATE_CONDITIONAL_MSG = '`%<current>s` returns a model which is ' \
                                 'always truthy.'

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

          return unless node&.send_type?
          return unless persist_method?(node, CREATE_PERSIST_METHODS)
          return if persisted_referenced?(assignment)

          add_offense_for_node(node, CREATE_MSG)
        end

        def on_send(node) # rubocop:disable Metrics/CyclomaticComplexity
          return unless persist_method?(node)
          return if return_value_assigned?(node)
          return if check_used_in_conditional(node)
          return if argument?(node)
          return if implicit_return?(node)
          return if explicit_return?(node)

          add_offense_for_node(node)
        end
        alias on_csend on_send

        def autocorrect(node)
          save_loc = node.loc.selector
          new_method = "#{node.method_name}!"

          ->(corrector) { corrector.replace(save_loc, new_method) }
        end

        private

        def add_offense_for_node(node, msg = MSG)
          name = node.method_name
          full_message = format(msg, prefer: "#{name}!", current: name.to_s)

          add_offense(node, location: :selector, message: full_message)
        end

        def right_assignment_node(assignment)
          node = assignment.node.child_nodes.first

          return node unless node&.block_type?

          node.send_node
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

        def assignable_node(node)
          assignable = node.block_node || node
          while node
            node = hash_parent(node) || array_parent(node)
            assignable = node if node
          end
          assignable
        end

        def hash_parent(node)
          pair = node.parent
          return unless pair&.pair_type?

          hash = pair.parent
          return unless hash&.hash_type?

          hash
        end

        def array_parent(node)
          array = node.parent
          return unless array&.array_type?

          array
        end

        def check_used_in_conditional(node)
          return false unless conditional?(node)

          unless MODIFY_PERSIST_METHODS.include?(node.method_name)
            add_offense_for_node(node, CREATE_CONDITIONAL_MSG)
          end

          true
        end

        def conditional?(node) # rubocop:disable Metrics/CyclomaticComplexity
          node = node.block_node || node

          condition = node.parent
          return false unless condition

          condition.if_type? || condition.case_type? ||
            condition.or_type? || condition.and_type? ||
            single_negative?(condition)
        end

        def allowed_receiver?(node)
          return false unless node.receiver
          return false unless cop_config['AllowedReceivers']

          cop_config['AllowedReceivers'].any? do |allowed_receiver|
            receiver_chain_matches?(node, allowed_receiver)
          end
        end

        def receiver_chain_matches?(node, allowed_receiver)
          allowed_receiver.split('.').reverse.all? do |receiver_part|
            node = node.receiver
            return false unless node

            if node.variable?
              node.node_parts.first == receiver_part.to_sym
            elsif node.send_type?
              node.method_name == receiver_part.to_sym
            elsif node.const_type?
              const_matches?(node.const_name, receiver_part)
            end
          end
        end

        # Const == Const
        # ::Const == ::Const
        # ::Const == Const
        # Const == ::Const
        # NameSpace::Const == Const
        # NameSpace::Const == NameSpace::Const
        # NameSpace::Const != ::Const
        # Const != NameSpace::Const
        def const_matches?(const, allowed_const)
          parts = allowed_const.split('::').reverse.zip(
            const.split('::').reverse
          )
          parts.all? do |(allowed_part, const_part)|
            allowed_part == const_part.to_s
          end
        end

        def implicit_return?(node)
          return false unless cop_config['AllowImplicitReturn']

          node = assignable_node(node)
          method = node.parent
          return unless method && (method.def_type? || method.block_type?)

          method.children.size == node.sibling_index + 1
        end

        def argument?(node)
          assignable_node(node).argument?
        end

        def explicit_return?(node)
          ret = assignable_node(node).parent
          ret && (ret.return_type? || ret.next_type?)
        end

        def return_value_assigned?(node)
          assignment = assignable_node(node).parent
          assignment&.lvasgn_type?
        end

        def persist_method?(node, methods = PERSIST_METHODS)
          methods.include?(node.method_name) &&
            expected_signature?(node) &&
            !allowed_receiver?(node)
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
