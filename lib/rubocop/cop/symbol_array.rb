# encoding: utf-8

module Rubocop
  module Cop
    class SymbolArray < Cop
      ERROR_MESSAGE = 'Use %i or %I for array of symbols.'

      def inspect(file, source, tokens, sexp)
        # %i and %I were introduced in Ruby 2.0
        unless RUBY_VERSION < '2.0.0'
          each(:array, sexp) do |s|
            array_elems = s[1]

            # no need to check empty arrays
            next unless array_elems && array_elems.size > 1

            symbol_array = array_elems.all? { |e| e[0] == :symbol_literal }

            if symbol_array
              add_offence(:convention,
                          all_positions(s).first.lineno,
                          ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
