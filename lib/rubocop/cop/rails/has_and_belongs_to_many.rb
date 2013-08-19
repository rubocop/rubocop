# encoding: utf-8

module Rubocop
  module Cop
    module Rails
      # This cop checks for the use of old-style attribute validation macros.
      class HasAndBelongsToMany < Cop
        MSG = 'Prefer has_many :through to has_and_belongs_to_many.'

        def on_send(node)
          receiver, method_name, *_args = *node

          if receiver.nil? && method_name == :has_and_belongs_to_many
            add_offence(:convention, node.loc.selector, MSG)
          end
        end
      end
    end
  end
end
