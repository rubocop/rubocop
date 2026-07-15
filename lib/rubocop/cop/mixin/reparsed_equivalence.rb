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

      # Like `parses_identically?`, but treats grouping parentheses as
      # transparent: single-child `begin` nodes are collapsed on both sides
      # before comparison, so removing a pair of grouping parentheses that
      # does not affect how the code parses counts as identical.
      def parses_identically_ignoring_grouping?(rewritten_source)
        rewritten = parse(rewritten_source)
        return false unless rewritten.valid_syntax?

        collapse_groupings(rewritten.ast) == collapsed_scope(processed_source.ast)
      end

      # The scoped counterpart of `parses_identically_ignoring_grouping?`:
      # compares `rewritten_fragment` against `scope_node` (a node whose
      # source parses standalone, e.g. a method definition), so only the
      # scope enclosing an edit needs to be reparsed.
      def parses_fragment_identically_ignoring_grouping?(scope_node, rewritten_fragment)
        rewritten = parse(rewritten_fragment)
        return false unless rewritten.valid_syntax?

        collapse_groupings(rewritten.ast) == collapsed_scope(scope_node)
      end

      def collapsed_scope(scope_node)
        @collapsed_scopes ||= {}.compare_by_identity
        @collapsed_scopes[scope_node] ||= collapse_groupings(scope_node)
      end

      def collapse_groupings(node)
        return node unless node.is_a?(::Parser::AST::Node)

        children = node.children.map { |child| collapse_groupings(child) }
        children = splice_nested_sequences(children) if %i[begin kwbegin].include?(node.type)

        if node.begin_type? && children.one? && children.first.is_a?(::Parser::AST::Node)
          children.first
        else
          node.updated(nil, children)
        end
      end

      # A parenthesized statement sequence inside another sequence is
      # equivalent to its statements spliced in place.
      def splice_nested_sequences(children)
        children.flat_map do |child|
          child.is_a?(::Parser::AST::Node) && child.begin_type? ? child.children : [child]
        end
      end
    end
  end
end
