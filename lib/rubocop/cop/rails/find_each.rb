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
        MSG = 'Use `find_each` instead of `each`.'.freeze

        SCOPE_METHODS = [:all, :where].freeze

        def on_send(node)
          receiver, second_method, _selector = *node
          return unless second_method == :each
          return if receiver.nil?

          _model, first_method = *receiver
          return unless SCOPE_METHODS.include?(first_method)
          return if method_chain(node).any? { |m| ignored_by_find_each?(m) }

          add_offense(node, node.loc.selector, MSG)
        end

        def autocorrect(node)
          each_loc = node.loc.selector

          ->(corrector) { corrector.replace(each_loc, 'find_each') }
        end

        private

        def method_chain(node)
          if (node.send_type? || node.block_type?) && !node.receiver.nil?
            if node.parent
              method_chain(node.parent) << node.method_name
            else
              [node.method_name]
            end
          else
            []
          end
        end

        def ignored_by_find_each?(relation_method)
          # Active Record's #find_each ignores various extra parameters
          [:order, :limit, :select].include?(relation_method)
        end
      end
    end
  end
end
