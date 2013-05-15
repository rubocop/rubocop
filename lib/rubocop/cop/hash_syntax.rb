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

          sym_indices = pairs.all? { |p| p.children.first.type == :sym }

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
    end
  end
end
