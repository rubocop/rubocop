# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks if the length a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
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

        def max_length
          MethodLength.config['Max']
        end

        def count_comments?
          MethodLength.config['CountComments']
        end

        private

        def check(node)
          method_length = calculate_length(node.loc.expression.source)

          if method_length > max_length
            message = sprintf(MSG, method_length, max_length)
            add_offence(:convention, node.loc.keyword, message)
          end
        end

        def calculate_length(source)
          lines = source.lines.to_a[1...-1]

          return 0 unless lines

          lines.map!(&:strip).reject!(&:empty?)

          lines.reject! { |line| line =~ /^\s*#/ } unless count_comments?

          lines.size
        end
      end
    end
  end
end
