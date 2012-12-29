# encoding: utf-8

module Rubocop
  module Cop
    class HashSyntax < Cop
      ERROR_MESSAGE = 'Ruby 1.8 hash syntax detected'

      def inspect(file, source, tokens, sexp)
        each(:assoclist_from_args, sexp) { |assoclist_from_args|
          keys = assoclist_from_args[1].map { |assoc_new| assoc_new[1][0] }
          # If at least one of the keys in the hash is neither a symbol (:a)
          # nor a label (a:), we can't require the new syntax.
          return if keys.find { |key|
            not [:symbol_literal, :@label].include?(key)
          }
        }
        each(:assoc_new, sexp) { |assoc_new|
          if assoc_new[1][0] == :symbol_literal
            index = assoc_new[1][1][1][-1][0] - 1
            add_offence(:convention, index, source[index], ERROR_MESSAGE)
          end
        }
      end
    end
  end
end
