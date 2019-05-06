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
        MSG = 'Use a string value for `class_name`.'

        def_node_matcher :association_with_reflection, <<-PATTERN
          (send nil? {:has_many :has_one :belongs_to} _
            (hash <$#reflection_class_name ...>)
          )
        PATTERN

        def_node_matcher :reflection_class_name, <<-PATTERN
          (pair (sym :class_name) [!dstr !str !sym])
        PATTERN

        def on_send(node)
          association_with_reflection(node) do |reflection_class_name|
            add_offense(node, location: reflection_class_name.loc.expression)
          end
        end
      end
    end
  end
end
