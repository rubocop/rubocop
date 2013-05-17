# encoding: utf-8

module Rubocop
  module Cop
    class WordArray < Cop
      MSG = 'Use %w or %W for array of words.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:array, sexp) do |s|
          next unless s.src.begin && s.src.begin.to_source == '['

          array_elems = s.children

          # no need to check empty arrays
          next unless array_elems && array_elems.size > 1

          string_array = array_elems.all? { |e| e.type == :str }

          if string_array && !complex_content?(array_elems)
            add_offence(:convention,
                        s.src.line,
                        MSG)
          end
        end
      end

      def complex_content?(arr_sexp)
        arr_sexp.each do |s|
          str_content = Util.strip_quotes(s.src.expression.to_source)
          return true unless str_content =~ /\A[\w-]+\z/
        end

        false
      end
    end
  end
end
