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
          # lambda.() does not have a selector
          return unless node.loc.selector
          op = node.loc.selector.source

          if OPS.include?(op)
            _receiver, _method, args = *node

            add_offence(node, :selector) if args == NIL_NODE
          end
        end
      end
    end
  end
end
