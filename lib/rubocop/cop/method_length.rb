# encoding: utf-8

module Rubocop
  module Cop
    class MethodLength < Cop
      MSG = 'Method has too many lines. [%d/%d]'

      def on_def(node)
        check(node)

        super
      end

      def on_defs(node)
        check(node)

        super
      end

      private

      def check(node)
        method_length = calculate_length(node.src.expression.to_source)

        max = MethodLength.config['Max']
        if method_length > max
          message = sprintf(MSG, method_length, max)
          add_offence(:convention, node.src.keyword.line, message)
        end
      end

      def calculate_length(source)
        lines = source.lines[1...-1]

        return 0 unless lines

        lines.map!(&:strip).reject!(&:empty?)

        unless MethodLength.config['CountComments']
          lines.reject! { |line| line =~ /^\s*#/ }
        end

        lines.size
      end
    end
  end
end
