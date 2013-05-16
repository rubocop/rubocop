# encoding: utf-8

module Rubocop
  module Cop
    class HashSyntax < Cop
      ERROR_MESSAGE = 'Ruby 1.8 hash syntax detected'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:hash, sexp) do |node|
          pairs = *node

          sym_indices = pairs.all? { |p| word_symbol_pair?(p) }

          if sym_indices
            pairs.each do |pair|
              if pair.src.operator && pair.src.operator.to_source == '=>'
                add_offence(:convention,
                            pair.src.line,
                            ERROR_MESSAGE)
              end
            end
          end
        end
      end

      private

      def word_symbol_pair?(pair)
        key, _value = *pair

        if key.type == :sym
          sym_name = key.to_a[0]

          sym_name =~ /\A\w+\z/
        else
          false
        end
      end
    end
  end
end
