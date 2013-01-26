# encoding: utf-8

module Rubocop
  module Cop
    module TernaryOperator
      def inspect(file, source, tokens, sexp)
        each(:ifop, sexp) do |ifop|
          if offends?(ifop)
            add_offence(:convention, all_positions(ifop).first.lineno,
                        error_message)
          end
        end
      end
    end

    class MultilineTernaryOperator < Cop
      include TernaryOperator

      def error_message
        'Avoid multi-line ?: (the ternary operator); use if/unless instead.'
      end

      def offends?(ifop)
        all_positions(ifop).map(&:lineno).uniq.size > 1
      end
    end

    class NestedTernaryOperator < Cop
      include TernaryOperator

      def error_message
        'Ternary operators must not be nested. Prefer if/else constructs ' +
          'instead.'
      end

      def offends?(ifop)
        ifop.flatten[1..-1].include?(:ifop)
      end
    end
  end
end
