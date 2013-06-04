# encoding: utf-8

module Rubocop
  module Cop
    class HashSyntax < Cop
      MSG = 'Ruby 1.8 hash syntax detected'

      def on_hash(node)
        pairs = *node

        sym_indices = pairs.all? { |p| word_symbol_pair?(p) }

        if sym_indices
          pairs.each do |pair|
            if pair.loc.operator && pair.loc.operator.source == '=>'
              add_offence(:convention,
                          pair.loc,
                          MSG)
            end
          end
        end

        super
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
