# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of the has_and_belongs_to_many macro.
      class HasAndBelongsToMany < Cop
        MSG = 'Prefer `has_many :through` to `has_and_belongs_to_many`.'

        def on_send(node)
          return unless command?(:has_and_belongs_to_many, node)
          add_offense(node, :selector)
        end
      end
    end
  end
end
