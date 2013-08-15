# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for comparison of something with nil using ==.
      #
      # @example
      #
      #  # bad
      #  if x == nil
      #  if x != nil
      #
      #  # good
      #  if x.nil?
      #  if !x.nil?
      class NilComparison < Cop
        MSG = 'Prefer the use of the nil? predicate.'

        OPS = %w(== === !=)

        NIL_NODE = s(:nil)

        def on_send(node)
          op = node.loc.selector.source

          if OPS.include?(op)
            _receiver, _method, args = *node

            if args == NIL_NODE
              add_offence(:convention, node.loc.selector, MSG)
            end
          end
        end
      end
    end
  end
end
