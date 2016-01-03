# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing comma in parameter lists and literals.
      #
      # @example
      #   # always bad
      #   a = [1, 2,]
      #
      #   # good if EnforcedStyleForMultiline is consistent_comma
      #   a = [
      #     1, 2,
      #     3,
      #   ]
      #
      #   # good if EnforcedStyleForMultiline is comma or consistent_comma
      #   a = [
      #     1,
      #     2,
      #   ]
      #
      #   # good if EnforcedStyleForMultiline is no_comma
      #   a = [
      #     1,
      #     2
      #   ]
      class TrailingComma < Cop
        include ArraySyntax
        include ConfigurableEnforcedStyle

        MSG = '%s comma after the last %s'

        def on_array(node)
          check_literal(node, 'item of %s array') if square_brackets?(node)
        end

        def on_hash(node)
          check_literal(node, 'item of %s hash')
        end

        def on_send(node)
          _receiver, _method_name, *args = *node
          return if args.empty?
          # It's impossible for a method call without parentheses to have
          # a trailing comma.
          return unless brackets?(node)

          check(node, args, 'parameter of %s method call',
                args.last.source_range.end_pos, node.source_range.end_pos)
        end

        private

        def parameter_name
          'EnforcedStyleForMultiline'
        end

        def check_literal(node, kind)
          return if node.children.empty?
          # A braceless hash is the last parameter of a method call and will be
          # checked as such.
          return unless brackets?(node)

          check(node, node.children, kind,
                node.children.last.source_range.end_pos,
                node.loc.end.begin_pos)
        end

        def check(node, items, kind, begin_pos, end_pos)
          sb = items.first.source_range.source_buffer

          after_last_item = Parser::Source::Range.new(sb, begin_pos, end_pos)

          return if heredoc?(after_last_item.source)

          comma_offset = after_last_item.source =~ /,/

          if comma_offset && !inside_comment?(after_last_item, comma_offset)
            unless should_have_comma?(style, node, items)
              extra_info = case style
                           when :comma
                             ', unless each item is on its own line'
                           when :consistent_comma
                             ', unless items are split onto multiple lines'
                           else
                             ''
                           end
              avoid_comma(kind, after_last_item.begin_pos + comma_offset, sb,
                          extra_info)
            end
          elsif should_have_comma?(style, node, items)
            put_comma(items, kind, sb)
          end
        end

        def should_have_comma?(style, node, items)
          [:comma, :consistent_comma].include?(style) &&
            multiline?(node) &&
            (items.size > 1 || items.last.hash_type?)
        end

        def inside_comment?(range, comma_offset)
          processed_source.comments.any? do |comment|
            comment_offset = comment.loc.expression.begin_pos - range.begin_pos
            comment_offset >= 0 && comment_offset < comma_offset
          end
        end

        def heredoc?(source_after_last_item)
          source_after_last_item =~ /\w/
        end

        # Returns true if the node has round/square/curly brackets.
        def brackets?(node)
          node.loc.end
        end

        # Returns true if the round/square/curly brackets of the given node are
        # on different lines, and each item within is on its own line, and the
        # closing bracket is on its own line.
        def multiline?(node)
          elements = if node.type == :send
                       _receiver, _method_name, *args = *node
                       args.flat_map do |a|
                         # For each argument, if it is a multi-line hash,
                         # then promote the hash elements to method arguments
                         # for the purpose of determining multi-line-ness.
                         if a.hash_type? && a.loc.first_line != a.loc.last_line
                           a.children
                         else
                           a
                         end
                       end
                     else
                       node.children
                     end

          # Without this check, Foo.new({}) is considered multiline, which
          # it should not be. Essentially, if there are no elements, the
          # expression can not be multiline.
          return if elements.empty?

          items = elements.map(&:source_range)
          if style == :consistent_comma
            items.each_cons(2).any? { |a, b| !on_same_line?(a, b) }
          else
            items << node.loc.end
            items.each_cons(2).all? { |a, b| !on_same_line?(a, b) }
          end
        end

        def on_same_line?(a, b)
          a.line + a.source.count("\n") == b.line
        end

        def avoid_comma(kind, comma_begin_pos, sb, extra_info)
          range = Parser::Source::Range.new(sb, comma_begin_pos,
                                            comma_begin_pos + 1)
          article = kind =~ /array/ ? 'an' : 'a'
          add_offense(range, range,
                      format(MSG, 'Avoid', format(kind, article)) +
                      "#{extra_info}.")
        end

        def put_comma(items, kind, sb)
          last_item = items.last
          return if last_item.type == :block_pass

          last_expr = last_item.source_range
          ix = last_expr.source.rindex("\n") || 0
          ix += last_expr.source[ix..-1] =~ /\S/
          range = Parser::Source::Range.new(sb, last_expr.begin_pos + ix,
                                            last_expr.end_pos)
          add_offense(range, range,
                      format(MSG, 'Put a', format(kind, 'a multiline') + '.'))
        end

        def autocorrect(range)
          lambda do |corrector|
            case range.source
            when ',' then corrector.remove(range)
            else          corrector.insert_after(range, ',')
            end
          end
        end
      end
    end
  end
end
