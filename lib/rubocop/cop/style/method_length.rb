# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks if the length a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class MethodLength < Cop
        include OnMethod
        include CodeLength

        private

        def on_method(node, _method_name, _args, _body)
          check(node)
        end

        def message
          'Method has too many lines. [%d/%d]'
        end

        def code_length(node)
          lines = node.loc.expression.source.lines.to_a[1..-2] || []

          lines.reject! { |line| irrelevant_line(line) }

          lines.size
        end
      end
    end
  end
end
