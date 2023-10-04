# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for debug calls (such as `debugger` or `binding.pry`) that should
      # not be kept for production code.
      #
      # The cop can be configured using `DebuggerMethods`. By default, a number of gems
      # debug entrypoints are configured (`Kernel`, `Byebug`, `Capybara`, `debug.rb`,
      # `Pry`, `Rails`, `RubyJard`, and `WebConsole`). Additional methods can be added.
      #
      # Specific default groups can be disabled if necessary:
      #
      # [source,yaml]
      # ----
      # Lint/Debugger:
      #   DebuggerMethods:
      #     WebConsole: ~
      # ----
      #
      # You can also add your own methods by adding a new category:
      #
      # [source,yaml]
      # ----
      # Lint/Debugger:
      #   DebuggerMethods:
      #     MyDebugger:
      #       MyDebugger.debug_this
      # ----
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
      #
      # @example DebuggerMethods: [my_debugger]
      #
      #   # bad (ok during development)
      #
      #   def some_method
      #     my_debugger
      #   end
      class Debugger < Base
        MSG = 'Remove debugger entry point `%<source>s`.'

        def on_send(node)
          return if !debugger_method?(node) || assumed_usage_context?(node)

          add_offense(node)
        end

        private

        def message(node)
          format(MSG, source: node.source)
        end

        def debugger_methods
          @debugger_methods ||= begin
            config = cop_config.fetch('DebuggerMethods', [])
            config.is_a?(Array) ? config : config.values.flatten
          end
        end

        def debugger_method?(send_node)
          return false if send_node.parent&.send_type? && send_node.parent.receiver == send_node

          debugger_methods.include?(chained_method_name(send_node))
        end

        def assumed_usage_context?(node)
          # Basically, debugger methods are not used as a method argument without arguments.
          return false unless node.arguments.empty? && node.each_ancestor(:send, :csend).any?
          return true if assumed_argument?(node)

          node.each_ancestor.none? do |ancestor|
            ancestor.block_type? || ancestor.numblock_type? || ancestor.lambda_or_proc?
          end
        end

        def chained_method_name(send_node)
          chained_method_name = send_node.method_name.to_s
          receiver = send_node.receiver
          while receiver
            name = receiver.send_type? ? receiver.method_name : receiver.const_name
            chained_method_name = "#{name}.#{chained_method_name}"
            receiver = receiver.receiver
          end
          chained_method_name
        end

        def assumed_argument?(node)
          parent = node.parent

          parent.call_type? || parent.literal? || parent.pair_type?
        end
      end
    end
  end
end
