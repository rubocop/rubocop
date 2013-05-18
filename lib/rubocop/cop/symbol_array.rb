# encoding: utf-8

module Rubocop
  module Cop
    class SymbolArray < Cop
      MSG = 'Use %i or %I for array of symbols.'

      def inspect(file, source, tokens, sexp)
        # %i and %I were introduced in Ruby 2.0
        unless RUBY_VERSION < '2.0.0'
          on_node(:array, sexp) do |s|
            next unless s.src.begin && s.src.begin.to_source == '['

            array_elems = s.children

            # no need to check empty arrays
            next unless array_elems && array_elems.size > 1

            symbol_array = array_elems.all? { |e| e.type == :sym }

            if symbol_array
              add_offence(:convention,
                          s.src.line,
                          MSG)
            end
          end
        end
      end
    end
  end
end
