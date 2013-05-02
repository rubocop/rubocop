# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLineBetweenDefs < Cop
      ERROR_MESSAGE = 'Use empty lines between defs.'

      def inspect(file, source, tokens, sexp)
        each_parent_of(:def, sexp) do |parent|
          defs = parent.select { |child| child[0] == :def }
          identifier_of_first_def = defs[0][1]
          current_row_ix = identifier_of_first_def[-1].lineno - 1
          # The first def doesn't need to have an empty line above it,
          # so we iterate starting at index 1.
          defs[1..-1].each do |child|
            next_row_ix = child[1][-1].lineno - 1
            if source[current_row_ix..next_row_ix].grep(/^[ \t]*$/).empty?
              add_offence(:convention, next_row_ix + 1, ERROR_MESSAGE)
            end
            current_row_ix = next_row_ix
          end
        end
      end
    end
  end
end
