# encoding: utf-8

module Rubocop
  module Cop
    module Rails
      # This cop checks for the use of the has_and_belongs_to_many macro.
      class HasAndBelongsToMany < Cop
        MSG = 'Prefer has_many :through to has_and_belongs_to_many.'

        def on_send(node)
          receiver, method_name, *_args = *node

          if receiver.nil? && method_name == :has_and_belongs_to_many
            convention(node, :selector)
          end
        end
      end
    end
  end
end
