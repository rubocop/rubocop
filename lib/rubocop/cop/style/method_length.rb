# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks if the length a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class MethodLength < Cop
        include CheckMethods
        include CodeLength

        private

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
