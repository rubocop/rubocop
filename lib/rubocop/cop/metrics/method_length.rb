# encoding: utf-8

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class MethodLength < Cop
        include OnMethod
        include OnDSLMethod
        include CodeLength

        private

        def on_method(node, _method_name, _args, _body)
          check_code_length(node)
        end

        def on_dsl_method(node)
          check_code_length(node)
        end

        def message(node, length, max_length)
          if node.type == :block
            format('Block passed to `%s` has too many lines. [%d/%d]',
                   dsl_method_name(node), length, max_length)
          else
            format('Method has too many lines. [%d/%d]', length, max_length)
          end
        end

        def code_length(node)
          lines = node.loc.expression.source.lines.to_a[1..-2] || []

          lines.reject! { |line| irrelevant_line?(line) }

          lines.size
        end
      end
    end
  end
end
