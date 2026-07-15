# frozen_string_literal: true

module RuboCop
  module Cop
    # Verifies that a candidate rewrite of the inspected source is a syntactic
    # no-op: the rewritten source must parse successfully and produce the same
    # AST as the original.
    #
    # This turns "is this piece of syntax redundant?" questions into a
    # parser-backed check instead of a hand-maintained enumeration of grammar
    # rules: instead of modeling which constructs make (for example) a line
    # continuation or a pair of parentheses significant, a cop can apply the
    # removal and let the parser answer.
    #
    # Note that comments are invisible to the AST, so rewrites that may touch
    # comment text must be guarded separately by the caller.
    module ReparsedEquivalence
      private

      # Whether `rewritten_source` parses to the same AST as the source under
      # inspection.
      def parses_identically?(rewritten_source)
        rewritten = parse(rewritten_source)

        rewritten.valid_syntax? && rewritten.ast == processed_source.ast
      end

      # Whether `rewritten_fragment` parses to the same AST as `scope_node`, a
      # node whose source parses standalone (e.g. a method definition).
      # Reparsing just the scope enclosing an edit is much cheaper than
      # reparsing the whole file.
      def parses_identically_to_node?(scope_node, rewritten_fragment)
        rewritten = parse(rewritten_fragment)

        rewritten.valid_syntax? && rewritten.ast == scope_node
      end
    end
  end
end
