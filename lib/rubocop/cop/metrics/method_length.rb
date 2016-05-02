# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length of a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class MethodLength < Cop
        include OnMethodDef
        include CodeLength

        private

        def on_method_def(node, _method_name, _args, _body)
          check_code_length(node)
        end

        def message(length, max_length)
          format('Method has too many lines. [%d/%d]', length, max_length)
        end

        def code_length(node)
          lines = node.source.lines.to_a[1..-2] || []

          lines.count { |line| !irrelevant_line(line) }
        end
      end
    end
  end
end
