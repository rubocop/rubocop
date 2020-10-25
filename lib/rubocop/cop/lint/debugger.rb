# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for calls to debugger or pry.
      #
      # @example
      #
      #   # bad (ok during development)
      #
      #   # using pry
      #   def some_method
      #     binding.pry
      #     do_something
      #   end
      #
      # @example
      #
      #   # bad (ok during development)
      #
      #   # using byebug
      #   def some_method
      #     byebug
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method
      #     do_something
      #   end
      class Debugger < Base
        include DebuggerMethods
        include ForbiddenReceivers

        MSG = 'Remove debugger entry point `%<source>s`.'

        def on_send(node)
          return unless debugger_method?(node.method_name)
          return if special_rule?(node)
          return if with_receiver?(node) && !forbidden_receiver?(node)

          add_offense(node)
        end

        private

        def message(node)
          format(MSG, source: node.source)
        end

        def with_receiver?(node)
          !!node.receiver
        end

        def special_rule?(node)
          return false unless node.receiver.is_a?(RuboCop::AST::ConstNode)
          return true if node.receiver.const_name == 'Kernel' && node.method?(:save_and_open_page)

          false
        end

        def forbidden_receiver?(node)
          receiver = case node.receiver
                     when RuboCop::AST::SendNode
                       node.receiver.method_name
                     when RuboCop::AST::ConstNode
                       node.receiver.const_name
                     end

          forbidden?(receiver)
        end
      end
    end
  end
end
