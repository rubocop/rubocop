# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of `all.each` and
      # change them to use `all.find_each` instead.
      #
      # @example
      #   # bad
      #   User.all.each
      #
      #   # good
      #   User.all.find_each
      class FindEach < Cop
        MSG = 'Use `find_each` instead of `each`.'

        SCOPE_METHODS = [:all, :where]

        def on_send(node)
          receiver, second_method, _selector = *node
          return unless second_method == :each
          return if receiver.nil?

          _model, first_method = *receiver
          return unless SCOPE_METHODS.include?(first_method)

          add_offense(node, node.loc.selector, MSG)
        end

        def autocorrect(node)
          each_loc = node.loc.selector

          ->(corrector) { corrector.replace(each_loc, 'find_each') }
        end
      end
    end
  end
end
