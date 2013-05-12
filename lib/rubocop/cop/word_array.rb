# encoding: utf-8

module Rubocop
  module Cop
    class WordArray < Cop
      ERROR_MESSAGE = 'Use %w or %W for array of words.'

      def inspect(file, source, tokens, sexp)
        each(:array, sexp) do |s|
          array_elems = s[1]

          # no need to check empty arrays
          next unless array_elems && array_elems.size > 1

          string_array = array_elems.all? { |e| e[0] == :string_literal }

          if string_array && !complex_content?(array_elems)
            add_offence(:convention,
                        all_positions(s).first.lineno,
                        ERROR_MESSAGE)
          end
        end
      end

      def complex_content?(arr_sexp)
        non_empty_strings = 0

        each(:@tstring_content, arr_sexp) do |content|
          non_empty_strings += 1
          return true unless content[1] =~ /\A[\w-]+\z/
        end

        # check for '' strings in the array
        non_empty_strings == arr_sexp.size ? false : true
      end
    end
  end
end
