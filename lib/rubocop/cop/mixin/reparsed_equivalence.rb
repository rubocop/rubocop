# frozen_string_literal: true

module RuboCop
  module Cop
    # Verifies that a candidate correction of the inspected source is a
    # syntactic no-op: the corrected source must parse successfully and produce
    # the same AST as the original.
    #
    # This turns "is this piece of syntax redundant?" questions into a
    # parser-backed check instead of a hand-maintained enumeration of grammar
    # rules: instead of modeling which constructs make (for example) a line
    # continuation or a pair of parentheses significant, a cop can apply the
    # correction and let the parser answer.
    #
    # Cops implement `#apply_reparse_correction(corrector, item)` and call
    # `verified_by_reparse(items)`, which returns the items whose corrections
    # are verified. Items sharing a reparse scope (the innermost method
    # definition or class/module body, which parse standalone and cannot
    # capture outer local variables) are verified together with a single
    # reparse, falling back to per-item verification when the batch does not
    # hold. Scope groups are keyed by node identity, since structurally
    # identical definitions in different places must not share a group.
    #
    # Two hooks customize the comparison:
    #
    # * `normalize_reparsed_ast(node)` - loosen strict tree equality where a
    #   cop's correction is equivalence-preserving beyond parse identity (such
    #   laws must be justified per cop; the default compares trees as-is).
    # * `preprocess_reparsed_source(source)` - rewrite both sides before
    #   parsing (e.g. to neutralize `__LINE__` when a correction legitimately
    #   shifts line numbers).
    #
    # `__FILE__` is handled by parsing with the original path, and fragments
    # containing `__LINE__` are verified by reparsing both sides so that
    # fragment line offsets cancel out.
    #
    # Note that comments are invisible to the AST, so corrections that may
    # touch comment text must be guarded separately by the caller.
    module ReparsedEquivalence
      # Above this size, verification does not reparse. What happens to such
      # items depends on `oversized`; in practice only machine-generated files
      # come near the limit.
      MAX_VERIFICATION_FRAGMENT_SIZE = 64 * 1024

      private

      # Returns the items whose corrections are verified. `oversized` controls
      # items whose reparse scope exceeds `MAX_VERIFICATION_FRAGMENT_SIZE`:
      # `:report` accepts them unverified (for cops whose offense logic stands
      # on its own and uses verification as a safety gate), `:verify` reparses
      # regardless of size (for cops where verification is the offense logic).
      def verified_by_reparse(items, oversized: :report)
        scope_groups(items).flat_map do |scope, group|
          if (oversized == :report && verification_too_large?(scope)) ||
             (group.size > 1 && corrections_verify?(scope, group))
            group
          else
            group.select { |item| corrections_verify?(scope, [item]) }
          end
        end
      end

      # Whether the exact correction for `item` produces source that still
      # parses, without requiring an equivalent AST. For corrections that
      # intentionally change the tree.
      def correction_parses?(item)
        corrector = Corrector.new(processed_source)
        apply_reparse_correction(corrector, item)

        parse(corrector.process, processed_source.path).valid_syntax?
      rescue ::Parser::ClobberingError
        false
      end

      # Hook: loosen strict tree equality for corrections that are
      # equivalence-preserving beyond parse identity.
      def normalize_reparsed_ast(node)
        node
      end

      # Hook: rewrite both sides before parsing.
      def preprocess_reparsed_source(source)
        source
      end

      def scope_groups(items)
        groups = {}.compare_by_identity
        items.each { |item| (groups[reparse_scope(item_range(item))] ||= []) << item }

        groups
      end

      def item_range(item)
        item.respond_to?(:source_range) ? item.source_range : item
      end

      # The innermost scope that both contains `range` and parses standalone.
      # Method definitions and class/module bodies neither capture outer local
      # variables nor continue an outer expression; blocks and single
      # statements do not qualify, since an outer local would reparse as a
      # method call.
      def reparse_scope(range)
        node = processed_source.ast
        scope = nil

        while node.is_a?(::Parser::AST::Node)
          scope = node if node.type?(:any_def, :class, :module, :sclass)
          node = node.children.find do |child|
            child.is_a?(::Parser::AST::Node) && child.source_range&.contains?(range)
          end
        end

        scope
      end

      def verification_too_large?(scope)
        (scope ? scope.source_range.size : processed_source.raw_source.size) >
          MAX_VERIFICATION_FRAGMENT_SIZE
      end

      def corrections_verify?(scope, items)
        corrector = Corrector.new(processed_source)
        items.each { |item| apply_reparse_correction(corrector, item) }
        corrected = corrector.process

        if scope
          fragment = corrected_scope_fragment(scope, corrected)
          parses_equivalently?(scope.source, scope, fragment)
        else
          parses_equivalently?(processed_source.raw_source, processed_source.ast, corrected)
        end
      rescue ::Parser::ClobberingError
        false
      end

      # The corrections' edits are all contained within the scope, so the
      # corrected fragment can be cut out of the corrected source by adjusting
      # for the edits' length delta.
      def corrected_scope_fragment(scope, corrected)
        delta = corrected.length - processed_source.raw_source.length
        scope_range = scope.source_range

        corrected[scope_range.begin_pos...(scope_range.end_pos + delta)]
      end

      # Both sides are parsed with the original path so that `__FILE__`
      # resolves identically. The original side is reparsed (instead of using
      # the already parsed node) when preprocessing altered it or it contains
      # `__LINE__`, whose values would otherwise differ from a fragment parsed
      # at a different line offset.
      def parses_equivalently?(original_source, original_ast, corrected_source)
        original_normalized = normalized_original(original_source, original_ast)
        return false unless original_normalized

        rewritten = parse(preprocess_reparsed_source(corrected_source), processed_source.path)
        rewritten.valid_syntax? && normalize_reparsed_ast(rewritten.ast) == original_normalized
      end

      def normalized_original(original_source, original_ast)
        original = preprocess_reparsed_source(original_source)
        if original != original_source || original_source.include?('__LINE__')
          reparsed = parse(original, processed_source.path).ast
          reparsed && normalize_reparsed_ast(reparsed)
        else
          @normalized_originals ||= {}.compare_by_identity
          @normalized_originals[original_ast] ||= normalize_reparsed_ast(original_ast)
        end
      end
    end
  end
end
