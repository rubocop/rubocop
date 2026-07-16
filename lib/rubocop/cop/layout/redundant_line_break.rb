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
        include ReparsedEquivalence
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
          # The exact single-line correction is verified to parse equivalently
          # before the offense is registered, so a join that would change how
          # the code parses is never reported or offered.
          return if verified_by_reparse([node], oversized: :verify).empty?

          add_offense(node) do |corrector|
            corrector.replace(node, to_single_line(node.source).strip)
          end
          ignore_node(node)
        end

        def apply_reparse_correction(corrector, node)
          corrector.replace(node, to_single_line(node.source).strip)
        end

        # Joining lines shifts the value of any later `__LINE__`, exactly as
        # any other line-removing correction does; neutralize it on both sides
        # with an identifier, which stays valid in every position the keyword
        # can appear in.
        def preprocess_reparsed_source(source)
          source.gsub(/\b__LINE__\b/, '__LINE0__')
        end

        def normalize_reparsed_ast(node)
          fold_string_concatenation(node)
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
