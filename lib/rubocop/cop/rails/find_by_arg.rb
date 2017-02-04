# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of `find_by(arg)` and
      # change them to use `find_by(column: arg)` instead.
      #
      # @example
      #   # bad
      #   User.find_by(1)
      #
      #   # good
      #   User.find_by(id: 1)
      class FindByArg < Cop
        MSG = '`find_by(arg)` may not work. Use `find_by(column: arg)` instead.'.freeze

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless method_name == :find_by
          return if args.all? { |arg| arg.is_a?(RuboCop::AST::HashNode) }
          add_offense(node, :expression)
        end
      end
    end
  end
end
