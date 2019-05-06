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
        MSG = 'Use `find_each` instead of `each`.'

        SCOPE_METHODS = %i[
          all eager_load includes joins left_joins left_outer_joins not preload
          references unscoped where
        ].freeze
        IGNORED_METHODS = %i[order limit select].freeze

        def on_send(node)
          return unless node.receiver&.send_type? &&
                        node.method?(:each)

          return unless SCOPE_METHODS.include?(node.receiver.method_name)
          return if method_chain(node).any? { |m| ignored_by_find_each?(m) }

          add_offense(node, location: :selector)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'find_each') }
        end

        private

        def method_chain(node)
          node.each_node(:send).map(&:method_name)
        end

        def ignored_by_find_each?(relation_method)
          # Active Record's #find_each ignores various extra parameters
          IGNORED_METHODS.include?(relation_method)
        end
      end
    end
  end
end
