# encoding: utf-8

module Rubocop
  module Cop
    class MethodLength < Cop
      MSG = 'Method has too many lines. [%d/%d]'

      def inspect(file, source, tokens, ast)
        on_node([:def, :defs], ast) do |s|
          def_start = s.src.keyword.line
          def_end = s.src.end.line
          length = calculate_length(def_start, def_end, source)

          max = MethodLength.config['Max']
          if length > max
            message = sprintf(MSG, length, max)
            add_offence(:convention, def_start, message)
          end
        end
      end

      private

      def calculate_length(def_start, def_end, source)
        # first we check for single line methods
        return 1 if def_start == def_end

        # we start counting after def and before end
        lines = source[def_start..(def_end - 2)].reject(&:empty?)

        unless MethodLength.config['CountComments']
          lines = lines.reject { |line| line =~ /^\s*#/ }
        end
        lines.size
      end
    end
  end
end
