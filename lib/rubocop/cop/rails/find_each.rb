# frozen_string_literal: true

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

        SCOPE_METHODS = [:all, :where, :not].freeze
        IGNORED_METHODS = [:order, :limit, :select].freeze

        def on_send(node)
          return unless node.receiver && node.method?(:each)

          return unless SCOPE_METHODS.include?(node.receiver.method_name)
          return if method_chain(node).any? { |m| ignored_by_find_each?(m) }

          add_offense(node, node.loc.selector, MSG)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'find_each') }
        end

        private

        def method_chain(node)
          [*node.ancestors, node].map(&:method_name)
        end

        def ignored_by_find_each?(relation_method)
          # Active Record's #find_each ignores various extra parameters
          IGNORED_METHODS.include?(relation_method)
        end
      end
    end
  end
end
