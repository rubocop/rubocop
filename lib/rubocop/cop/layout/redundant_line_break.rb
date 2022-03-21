# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks whether certain expressions, e.g. method calls, that could fit
      # completely on a single line, are broken up into multiple lines unnecessarily.
      #
      # @example any configuration
      #   # bad
      #   foo(
      #     a,
      #     b
      #   )
      #
      #   puts 'string that fits on ' \
      #        'a single line'
      #
      #   things
      #     .select { |thing| thing.cond? }
      #     .join('-')
      #
      #   # good
      #   foo(a, b)
      #
      #   puts 'string that fits on a single line'
      #
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
        extend AutoCorrector

        MSG = 'Redundant line break detected.'

        def on_send(node)
          # Include "the whole expression".
          node = node.parent while convertible_block?(node) ||
                                   node.parent.is_a?(RuboCop::AST::BinaryOperatorNode) ||
                                   node.parent&.send_type?

          return unless offense?(node) && !part_of_ignored_node?(node)

          register_offense(node)
        end

        private

        def check_assignment(node, _rhs)
          return unless offense?(node)

          register_offense(node)
        end

        def register_offense(node)
          add_offense(node) do |corrector|
            corrector.replace(node.source_range, to_single_line(node.source).strip)
          end
          ignore_node(node)
        end

        def offense?(node)
          return false if configured_to_not_be_inspected?(node)

          node.multiline? && !too_long?(node) && suitable_as_single_line?(node)
        end

        def configured_to_not_be_inspected?(node)
          return true if other_cop_takes_precedence?(node)

          !cop_config['InspectBlocks'] && (node.block_type? ||
                                           node.each_descendant(:block).any?(&:multiline?))
        end

        def other_cop_takes_precedence?(node)
          single_line_block_chain_enabled? && node.each_descendant(:block).any? do |block_node|
            block_node.parent.send_type? && block_node.parent.loc.dot && !block_node.multiline?
          end
        end

        def single_line_block_chain_enabled?
          @config.for_cop('Layout/SingleLineBlockChain')['Enabled']
        end

        def suitable_as_single_line?(node)
          !comment_within?(node) &&
            node.each_descendant(:if, :case, :kwbegin, :def).none? &&
            node.each_descendant(:dstr, :str).none?(&:heredoc?) &&
            node.each_descendant(:begin).none? { |b| b.first_line != b.last_line }
        end

        def convertible_block?(node)
          parent = node.parent
          parent&.block_type? && node == parent.send_node &&
            (node.parenthesized? || !node.arguments?)
        end

        def comment_within?(node)
          processed_source.comments.map(&:loc).map(&:line).any? do |comment_line_number|
            comment_line_number >= node.first_line && comment_line_number <= node.last_line
          end
        end

        def too_long?(node)
          lines = processed_source.lines[(node.first_line - 1)...node.last_line]
          to_single_line(lines.join("\n")).length > max_line_length
        end

        def to_single_line(source)
          source
            .gsub(/" *\\\n\s*'/, %q(" + ')) # Double quote, backslash, and then single quote
            .gsub(/' *\\\n\s*"/, %q(' + ")) # Single quote, backslash, and then double quote
            .gsub(/(["']) *\\\n\s*\1/, '')  # Double or single quote, backslash, then same quote
            .gsub(/\n\s*(?=\.\w)/, '')      # Extra space within method chaining
            .gsub(/\s*\\?\n\s*/, ' ')       # Any other line break, with or without backslash
        end

        def max_line_length
          config.for_cop('Layout/LineLength')['Max']
        end
      end
    end
  end
end
