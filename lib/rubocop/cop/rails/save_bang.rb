# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop identifies possible cases where Active Record save! or related
      # should be used instead of save because the model might have failed to
      # save and an exception is better than unhandled failure.
      #
      # This will ignore calls that are assigned to a variable or used as the
      # condition in an if/unless statement.  It will also ignore any call with
      # more than 2 arguments as that is likely not an Active Record call or
      # if a Model.update(id, attributes) call.
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
      class SaveBang < Cop
        MSG = 'Use `%s` instead of `%s` if the return value is not checked.'
              .freeze

        PERSIST_METHODS = [:save, :create, :update, :destroy,
                           :first_or_create, :find_or_create_by].freeze

        def on_send(node)
          return unless PERSIST_METHODS.include?(node.method_name)
          return if return_value_used?(node)
          return unless expected_signature?(node)

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

        # Ignore simple assignment or if condition
        def return_value_used?(node)
          return false unless node.parent
          node.parent.lvasgn_type? ||
            (node.parent.block_type? && node.parent.parent &&
              node.parent.parent.lvasgn_type?) ||
            (node.parent.if_type? && node.sibling_index.zero?)
        end

        # Check argument signature as no arguments or one hash
        def expected_signature?(node)
          node.method_args.empty? ||
            (node.method_args.length == 1 &&
              node.method_name != :destroy &&
              (node.method_args.first.hash_type? ||
              !node.method_args.first.literal?))
        end
      end
    end
  end
end
