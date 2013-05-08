# encoding: utf-8

module Rubocop
  module Cop
    class UnlessElse < Cop
      ERROR_MESSAGE = 'Never use unless with else. Rewrite these with the ' +
        'positive case first.'

      def inspect(file, source, tokens, sexp)
        each(:unless, sexp) do |unless_sexp|
          if unless_sexp.compact.any? { |s| s[0] == :else }
            add_offence(:convention, all_positions(unless_sexp).first.lineno,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
