# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for debug calls (such as `debugger` or `binding.pry`) that should
      # not be kept for production code.
      #
      # The cop can be configured using `DebuggerMethods`. By default, a number of gems
      # debug entrypoints are configured (`Kernel`, `Byebug`, `Capybara`, `Pry`, `Rails`,
      # and `WebConsole`). Additional methods can be added.
      #
      # Specific default groups can be disabled if necessary:
      #
      # [source,yaml]
      # ----
      # Lint/Debugger:
      #   WebConsole: ~
      # ----
      #
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

        RESTRICT_ON_SEND = [].freeze

        # @!method kernel?(node)
        def_node_matcher :kernel?, <<~PATTERN
          (const {nil? cbase} :Kernel)
        PATTERN

        # @!method valid_receiver?(node, arg1)
        def_node_matcher :valid_receiver?, <<~PATTERN
          {
            (const {nil? cbase} %1)
            (send {nil? #kernel?} %1)
          }
        PATTERN

        def on_send(node)
          return unless debugger_method?(node)

          add_offense(node)
        end

        private

        def message(node)
          format(MSG, source: node.source)
        end

        def debugger_methods
          @debugger_methods ||= begin
            config = cop_config.fetch('DebuggerMethods', [])
            values = config.is_a?(Array) ? config : config.values.flatten
            values.map do |v|
              next unless v

              *receiver, method_name = v.split('.')
              {
                receiver: receiver.empty? ? nil : receiver.join.to_sym,
                method_name: method_name.to_sym
              }
            end.compact
          end
        end

        def debugger_method?(send_node)
          debugger_methods.any? do |method|
            next unless method[:method_name] == send_node.method_name

            if method[:receiver].nil?
              send_node.receiver.nil?
            else
              valid_receiver?(send_node.receiver, method[:receiver])
            end
          end
        end
      end
    end
  end
end
