# encoding: utf-8

module Rubocop
  module Cop
    class SingleLineMethods < Cop
      ERROR_MESSAGE = 'Avoid single-line methods.'

      def inspect(file, source, tokens, sexp)
        if SingleLineMethods.allow_if_method_is_empty
          is_empty = empty_methods(sexp)
        end

        lineno_of_def = nil
        possible_offence = false

        tokens.each_with_index do |token, ix|
          if possible_offence
            if token.pos.lineno > lineno_of_def
              possible_offence = false
            elsif [token.type, token.text] == [:on_kw, 'end']
              add_offence(:convention, lineno_of_def, ERROR_MESSAGE)
            end
          end

          if [token.type, token.text] == [:on_kw, 'def']
            lineno_of_def = token.pos.lineno
            name_pos = tokens[ix..-1].find { |t| t.type == :on_ident }.pos
            possible_offence = if SingleLineMethods.allow_if_method_is_empty
                                 !is_empty[name_pos]
                               else
                                 true
                               end
          end
        end
      end

      def self.allow_if_method_is_empty
        return true if SingleLineMethods.config.nil?
        allow = SingleLineMethods.config['AllowIfMethodIsEmpty']
        allow.nil? || allow
      end

      private

      # Returns a hash mapping positions of method names to booleans
      # saying whether or not the method is empty.
      def empty_methods(sexp)
        is_empty = {}
        # Since def is a keyword, def: can confuse the editor. Hence
        # Ruby 1.8 hash syntax is used here.
        # rubocop:disable HashSyntax
        { :def => [1, 3], :defs => [3, 5] }.each do |key, offsets|
          each(key, sexp) do |d|
            method_name_pos = d[offsets.first][-1]
            is_empty[method_name_pos] =
              (d[offsets.last] == [:bodystmt, [[:void_stmt]], nil, nil, nil])
          end
        end
        is_empty
      end
    end
  end
end
