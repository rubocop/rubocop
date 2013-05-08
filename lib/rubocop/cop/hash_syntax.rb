# encoding: utf-8

module Rubocop
  module Cop
    class HashSyntax < Cop
      ERROR_MESSAGE = 'Ruby 1.8 hash syntax detected'

      def inspect(file, source, tokens, sexp)
        each(:assoclist_from_args, sexp) do |assoclist_from_args|
          keys = assoclist_from_args[1].map { |assoc_new| assoc_new[1][0] }
          # If at least one of the keys in the hash is neither a symbol (:a)
          # nor a label (a:), we can't require the new syntax.
          return if keys.any? do |key|
            ![:symbol_literal, :@label].include?(key)
          end
        end
        each(:assoc_new, sexp) do |assoc_new|
          if assoc_new[1][0] == :symbol_literal
            add_offence(:convention, assoc_new[1][1][1][-1].lineno,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
