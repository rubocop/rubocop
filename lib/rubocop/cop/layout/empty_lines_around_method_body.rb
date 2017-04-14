# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks if empty lines exist around the bodies of methods.
      #
      # @example
      #
      #   # good
      #
      #   def foo
      #     ...
      #   end
      #
      #   # bad
      #
      #   def bar
      #
      #     ...
      #
      #   end
      class EmptyLinesAroundMethodBody < Cop
        include EmptyLinesAroundBody
        include OnMethodDef

        KIND = 'method'.freeze

        def on_method_def(node, _method_name, _args, body)
          check(node, body)
        end

        private

        def style
          :no_empty_lines
        end
      end
    end
  end
end
