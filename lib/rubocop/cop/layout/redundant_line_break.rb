# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks whether certain expressions, e.g. method calls, that could fit
      # completely on a single line, are broken up into multiple lines unnecessarily.
      #
      # @example
      #   # bad
      #   foo(
      #     a,
      #     b
      #   )
      #
      #   # good
      #   foo(a, b)
      #
      #   # bad
      #   puts 'string that fits on ' \
      #        'a single line'
      #
      #   # good
      #   puts 'string that fits on a single line'
      #
      #   # bad
      #   things
      #     .select { |thing| thing.cond? }
      #     .join('-')
      #
      #   # good
      #   things.select { |thing| thing.cond? }.join('-')
      #
      # @example InspectBlocks: false (default)
      #   # good
      #   foo(a) do |x|
      #     puts x
      #   end
      #
      # @example InspectBlocks: true
      #   # bad
      #   foo(a) do |x|
      #     puts x
      #   end
      #
      #   # good
      #   foo(a) { |x| puts x }
      #
      class RedundantLineBreak < Base
        include CheckAssignment
        include CheckSingleLineSuitability
        extend AutoCorrector

        MSG = 'Redundant line break detected.'

        def on_lvasgn(node)
          super unless end_with_percent_blank_string?(processed_source)
        end

        def on_send(node)
          # Include "the whole expression".
          node = node.parent while node.parent&.send_type? ||
                                   convertible_block?(node) ||
                                   node.parent.is_a?(RuboCop::AST::BinaryOperatorNode)

          return unless offense?(node) && !part_of_ignored_node?(node)

          register_offense(node)
        end
        alias on_csend on_send

        private

        def end_with_percent_blank_string?(processed_source)
          processed_source.buffer.source.end_with?("%\n\n")
        end

        def check_assignment(node, _rhs)
          return unless offense?(node)

          register_offense(node)
        end

        def register_offense(node)
          return unless verified_correction?(node)

          add_offense(node) do |corrector|
            corrector.replace(node, to_single_line(node.source).strip)
          end
          ignore_node(node)
        end

        # The exact single-line correction is verified to parse to the same
        # AST before the offense is registered, so a join that would change
        # how the code parses is never reported or offered. When the node lies
        # within a method definition or class/module body (which parse
        # standalone), only that scope is reparsed.
        def verified_correction?(node)
          corrector = Corrector.new(processed_source)
          corrector.replace(node, to_single_line(node.source).strip)
          corrected = corrector.process
          scope = reparse_scope(node)

          if scope
            parses_equivalently?(scope.source, scope, corrected_scope_fragment(scope, corrected))
          else
            parses_equivalently?(processed_source.raw_source, processed_source.ast, corrected)
          end
        end

        def reparse_scope(node)
          scope = node.each_ancestor(:any_def, :class, :module, :sclass).first
          scope if scope&.source_range&.contains?(node.source_range)
        end

        def corrected_scope_fragment(scope, corrected)
          delta = corrected.length - processed_source.raw_source.length
          scope_range = scope.source_range

          corrected[scope_range.begin_pos...(scope_range.end_pos + delta)]
        end

        # Both sides are parsed with the original path so that `__FILE__`
        # resolves identically. When the fragment uses `__LINE__`, both sides
        # are reparsed with the keyword neutralized: joining lines shifts the
        # value of any later `__LINE__`, exactly as any other line-removing
        # correction does, and that shift should not block the offense.
        def parses_equivalently?(original, original_ast, corrected)
          if original.include?('__LINE__')
            original_ast = parse(neutralize_line_keyword(original), processed_source.path).ast
            corrected = neutralize_line_keyword(corrected)
          end

          rewritten = parse(corrected, processed_source.path)
          return false unless rewritten.valid_syntax? && original_ast

          fold_string_concatenation(rewritten.ast) == fold_string_concatenation(original_ast)
        end

        def neutralize_line_keyword(source)
          # The replacement must stay valid in every position `__LINE__` can
          # appear in (expression, symbol, string content); an ordinary
          # identifier parses symmetrically on both sides.
          source.gsub(/\b__LINE__\b/, '__LINE0__')
        end

        # Joining lines merges split string literals (`"a" \<newline> "b"` into
        # `"ab"`) and turns mixed-quote pairs into `+` concatenation, which
        # changes the tree but not the resulting string. Normalize all string
        # concatenation to a canonical form before comparing: nested
        # concatenations are flattened and adjacent literal parts merged.
        def fold_string_concatenation(node)
          return node unless node.is_a?(::Parser::AST::Node)

          children = node.children.map { |child| fold_string_concatenation(child) }
          node = node.updated(nil, children)

          parts = string_concatenation_parts(node)
          return node unless parts

          merged = merge_string_parts(parts)
          if merged.one? && merged.first.str_type?
            node.updated(:str, merged.first.children)
          else
            node.updated(:dstr, merged)
          end
        end

        def string_concatenation_parts(node)
          case node.type
          when :dstr
            node.children
          when :send
            parts = [node.receiver, *node.arguments]
            parts if node.method?(:+) && parts.all? { |part| stringish?(part) }
          end
        end

        def merge_string_parts(parts)
          flattened = parts.flat_map do |part|
            part.is_a?(::Parser::AST::Node) && part.dstr_type? ? part.children : [part]
          end

          flattened.chunk_while { |left, right| plain_string?(left) && plain_string?(right) }
                   .map { |chunk| merge_plain_strings(chunk) }
        end

        def merge_plain_strings(chunk)
          return chunk.first if chunk.one?

          chunk.first.updated(:str, [chunk.map { |part| part.children.first }.join])
        end

        def stringish?(node)
          node.is_a?(::Parser::AST::Node) && %i[str dstr].include?(node.type)
        end

        def plain_string?(node)
          node.is_a?(::Parser::AST::Node) && node.str_type? && node.children.one?
        end

        def offense?(node)
          return false unless node.multiline? && suitable_as_single_line?(node)
          return require_backslash?(node) if node.operator_keyword?

          !index_access_call_chained?(node) && !configured_to_not_be_inspected?(node)
        end

        def require_backslash?(node)
          processed_source.lines[node.loc.operator.line - 1].end_with?('\\')
        end

        def index_access_call_chained?(node)
          return false unless node.send_type? && node.method?(:[])

          node.children.first.send_type? && node.children.first.method?(:[])
        end

        def configured_to_not_be_inspected?(node)
          return true if other_cop_takes_precedence?(node)
          return false if cop_config['InspectBlocks']

          node.any_block_type? || any_descendant?(node, :any_block, &:multiline?)
        end

        def other_cop_takes_precedence?(node)
          single_line_block_chain_enabled? && any_descendant?(node, :any_block) do |block_node|
            next unless (parent = block_node.parent)

            parent.call_type? && parent.loc.dot && block_node.single_line?
          end
        end

        def single_line_block_chain_enabled?
          @config.cop_enabled?('Layout/SingleLineBlockChain')
        end

        def convertible_block?(node)
          return false unless (parent = node.parent)

          parent.any_block_type? && node == parent.send_node &&
            (node.parenthesized? || !node.arguments?)
        end
      end
    end
  end
end
