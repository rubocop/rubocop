# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks if the value of the option `class_name`, in
      # the definition of a reflection is a string.
      #
      # @example
      #   # bad
      #   has_many :accounts, class_name: Account
      #   has_many :accounts, class_name: Account.name
      #
      #   # good
      #   has_many :accounts, class_name: 'Account'
      class ReflectionClassName < Cop
        MSG = 'Use a string value for `class_name`.'.freeze

        def_node_matcher :association_with_options?, <<-PATTERN
          (send nil? {:has_many :has_one :belongs_to} _ (hash $...))
        PATTERN

        def_node_search :reflection_class_name, <<-PATTERN
          (pair (sym :class_name) [!str !sym])
        PATTERN

        def on_send(node)
          return unless association_with_options?(node)

          reflection_class_name = reflection_class_name(node).first
          return unless reflection_class_name

          add_offense(node, location: reflection_class_name.loc.expression)
        end
      end
    end
  end
end
