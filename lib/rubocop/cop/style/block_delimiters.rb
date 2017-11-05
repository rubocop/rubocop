# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Check for uses of braces or do/end around single line or
      # multi-line blocks.
      #
      # @example
      #   # bad - single line block
      #   collection.each do |item| item.method(x) end
      #
      #   # good - single line block
      #   collection.each { |item| item.method(x) }
      #
      #   # bad - multi-line block
      #   things.map { |thing|
      #     something = thing.some_method
      #     proces(something, something_else)
      #   }
      #
      #   # good - multi-line block
      #   things.map do |thing|
      #     something = thing.some_method
      #     proces(something, something_else)
      #   end
      #
      class BlockDelimiters < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          return unless node.arguments?
          return if node.parenthesized? || node.operator_method?

          node.arguments.each do |arg|
            get_blocks(arg) do |block|
              # If there are no parentheses around the arguments, then braces
              # and do-end have different meaning due to how they bind, so we
              # allow either.
              ignore_node(block)
            end
          end
        end

        def on_block(node)
          return if ignored_node?(node)

          add_offense(node, location: :begin) unless proper_block_style?(node)
        end

        private

        def line_count_based_message(node)
          if block_length(node) > 0
            'Avoid using `{...}` for multi-line blocks.'
          else
            'Prefer `{...}` over `do...end` for single-line blocks.'
          end
        end

        def semantic_message(node)
          block_begin = node.loc.begin.source

          if block_begin == '{'
            'Prefer `do...end` over `{...}` for procedural blocks.'
          else
            'Prefer `{...}` over `do...end` for functional blocks.'
          end
        end

        def braces_for_chaining_message(node)
          if block_length(node) > 0
            if return_value_chaining?(node)
              'Prefer `{...}` over `do...end` for multi-line chained blocks.'
            else
              'Prefer `do...end` for multi-line blocks without chaining.'
            end
          else
            'Prefer `{...}` over `do...end` for single-line blocks.'
          end
        end

        def message(node)
          case style
          when :line_count_based    then line_count_based_message(node)
          when :semantic            then semantic_message(node)
          when :braces_for_chaining then braces_for_chaining_message(node)
          end
        end

        def autocorrect(node)
          return if correction_would_break_code?(node)

          if node.braces?
            replace_braces_with_do_end(node.loc)
          else
            replace_do_end_with_braces(node.loc)
          end
        end

        def replace_braces_with_do_end(loc)
          b = loc.begin
          e = loc.end

          lambda do |corrector|
            corrector.insert_before(b, ' ') unless whitespace_before?(b)
            corrector.insert_before(e, ' ') unless whitespace_before?(e)
            corrector.insert_after(b, ' ') unless whitespace_after?(b)
            corrector.replace(b, 'do')
            corrector.replace(e, 'end')
          end
        end

        def replace_do_end_with_braces(loc)
          b = loc.begin
          e = loc.end

          lambda do |corrector|
            corrector.insert_after(b, ' ') unless whitespace_after?(b, 2)

            corrector.replace(b, '{')
            corrector.replace(e, '}')
          end
        end

        def whitespace_before?(range)
          range.source_buffer.source[range.begin_pos - 1, 1] =~ /\s/
        end

        def whitespace_after?(range, length = 1)
          range.source_buffer.source[range.begin_pos + length, 1] =~ /\s/
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def get_blocks(node, &block)
          case node.type
          when :block
            yield node
          when :send
            get_blocks(node.receiver, &block) if node.receiver
          when :hash
            # A hash which is passed as method argument may have no braces
            # In that case, one of the K/V pairs could contain a block node
            # which could change in meaning if do...end replaced {...}
            return if node.braces?
            node.each_child_node { |child| get_blocks(child, &block) }
          when :pair
            node.each_child_node { |child| get_blocks(child, &block) }
          end
        end
        # rubocop:enable Metrics/CyclimaticComplexity

        def proper_block_style?(node)
          return true if ignored_method?(node.method_name)

          case style
          when :line_count_based    then line_count_based_block_style?(node)
          when :semantic            then semantic_block_style?(node)
          when :braces_for_chaining then braces_for_chaining_style?(node)
          end
        end

        def line_count_based_block_style?(node)
          node.multiline? ^ node.braces?
        end

        def semantic_block_style?(node)
          method_name = node.method_name

          if node.braces?
            functional_method?(method_name) || functional_block?(node)
          else
            procedural_method?(method_name) || !return_value_used?(node)
          end
        end

        def braces_for_chaining_style?(node)
          block_length = block_length(node)
          block_begin = node.loc.begin.source

          block_begin == if block_length > 0
                           (return_value_chaining?(node) ? '{' : 'do')
                         else
                           '{'
                         end
        end

        def return_value_chaining?(node)
          node.parent && node.parent.send_type? && node.parent.dot?
        end

        def correction_would_break_code?(node)
          return unless node.keywords?

          node.send_node.arguments? && !node.send_node.parenthesized?
        end

        def ignored_method?(method_name)
          cop_config['IgnoredMethods'].map(&:to_sym).include?(method_name)
        end

        def functional_method?(method_name)
          cop_config['FunctionalMethods'].map(&:to_sym).include?(method_name)
        end

        def functional_block?(node)
          return_value_used?(node) || return_value_of_scope?(node)
        end

        def procedural_method?(method_name)
          cop_config['ProceduralMethods'].map(&:to_sym).include?(method_name)
        end

        def return_value_used?(node)
          return unless node.parent

          # If there are parentheses around the block, check if that
          # is being used.
          if node.parent.begin_type?
            return_value_used?(node.parent)
          else
            node.parent.assignment? || node.parent.send_type?
          end
        end

        def return_value_of_scope?(node)
          return unless node.parent

          conditional?(node.parent) || array_or_range?(node.parent) ||
            node.parent.children.last == node
        end

        def conditional?(node)
          node.if_type? || node.or_type? || node.and_type?
        end

        def array_or_range?(node)
          node.array_type? || node.irange_type? || node.erange_type?
        end
      end
    end
  end
end
