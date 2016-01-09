# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks if empty lines around the bodies of methods match
      # the configuration.
      #
      # @example
      #
      #   def something(arg)
      #
      #     ...
      #   end
      #
      class EmptyLinesAroundMethodBody < Cop
        include EmptyLinesAroundBody
        include OnMethodDef

        KIND = 'method'.freeze

        private

        def on_method_def(node, _method_name, _args, body)
          check(node, body)
        end

        # Override ConfigurableEnforcedStyle#style and hard-code
        # configuration. It's difficult to imagine that anybody would want
        # empty lines around a method body, so we don't make it configurable.
        def style
          :no_empty_lines
        end
      end
    end
  end
end
