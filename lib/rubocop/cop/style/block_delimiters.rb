# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Check for uses of braces or do/end around single line or
      # multi-line blocks.
      class BlockDelimiters < Cop
        include ConfigurableEnforcedStyle

        def_node_matcher :block_method_name, '(block (send _ $_ ...) ...)'

        def on_send(node)
          _receiver, method_name, *args = *node
          return if args.empty?
          return if parentheses?(node) || operator?(method_name)

          get_blocks(args.last) do |block|
            # If there are no parentheses around the arguments, then braces and
            # do-end have different meaning due to how they bind, so we allow
            # either.
            ignore_node(block)
          end
        end

        def on_block(node)
          return if ignored_node?(node)
          return if proper_block_style?(node)

          add_offense(node, :begin)
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
          when :line_count_based
            line_count_based_message(node)
          when :semantic
            semantic_message(node)
          when :braces_for_chaining
            braces_for_chaining_message(node)
          end
        end

        def autocorrect(node)
          return if correction_would_break_code?(node)

          lambda do |corrector|
            b = node.loc.begin
            e = node.loc.end
            if b.is?('{')
              corrector.insert_before(b, ' ') unless whitespace_before?(b)
              corrector.insert_before(e, ' ') unless whitespace_before?(e)
              corrector.replace(b, 'do')
              corrector.replace(e, 'end')
            else
              corrector.replace(b, '{')
              corrector.replace(e, '}')
            end
          end
        end

        def whitespace_before?(node)
          node.source_buffer.source[node.begin_pos - 1, 1] =~ /\s/
        end

        def get_blocks(node, &block)
          case node.type
          when :block
            yield node
          when :send
            receiver, _method_name, *_args = *node
            get_blocks(receiver, &block) if receiver
          when :hash
            # A hash which is passed as method argument may have no braces
            # In that case, one of the K/V pairs could contain a block node
            # which could change in meaning if do...end replaced {...}
            return if node.loc.begin
            node.children.each { |child| get_blocks(child, &block) }
          when :pair
            node.children.each { |child| get_blocks(child, &block) }
          end
          nil
        end

        def proper_block_style?(node)
          case style
          when :line_count_based
            line_count_based_block_style?(node)
          when :semantic
            semantic_block_style?(node)
          when :braces_for_chaining
            braces_for_chaining_style?(node)
          end
        end

        def line_count_based_block_style?(node)
          block_begin = node.loc.begin.source

          (block_length(node) > 0) ^ (block_begin == '{')
        end

        def semantic_block_style?(node)
          method_name = block_method_name(node)
          return true if ignored_method?(method_name)

          block_begin = node.loc.begin.source

          if block_begin == '{'
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
          node.parent && node.parent.send_type? && node.parent.loc.dot
        end

        def correction_would_break_code?(node)
          if node.loc.begin.is?('do')
            # Converting `obj.method arg do |x| end` to use `{}` would cause
            # a syntax error.
            send = node.children.first
            _receiver, _method_name, *args = *send
            !args.empty? && !parentheses?(send)
          end
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
