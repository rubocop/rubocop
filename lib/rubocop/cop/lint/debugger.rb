# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for calls to debugger or pry.
      # The cop can be configured to define which methods and receivers must be fixed.
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
        MSG = 'Remove debugger entry point `%<source>s`.'

        RESTRICT_ON_SEND = [].freeze

        def on_send(node)
          return unless debugger_method?(node.method_name)
          return if !node.receiver.nil? && !debugger_receiver?(node)

          add_offense(node)
        end

        private

        def message(node)
          format(MSG, source: node.source)
        end

        def debugger_method?(name)
          cop_config.fetch('DebuggerMethods', []).include?(name.to_s)
        end

        def debugger_receiver?(node)
          receiver = case node.receiver
                     when RuboCop::AST::SendNode
                       node.receiver.method_name
                     when RuboCop::AST::ConstNode
                       node.receiver.const_name
                     end

          cop_config.fetch('DebuggerReceivers', []).include?(receiver.to_s)
        end
      end
    end
  end
end
