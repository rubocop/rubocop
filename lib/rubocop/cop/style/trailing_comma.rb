# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for trailing comma in parameter lists and literals.
      class TrailingComma < Cop
        include ArraySyntax
        include ConfigurableEnforcedStyle

        MSG = '%s comma after the last %s.'

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
                args.last.loc.expression.end_pos, node.loc.expression.end_pos)
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
                node.children.last.loc.expression.end_pos,
                node.loc.end.begin_pos)
        end

        def check(node, items, kind, begin_pos, end_pos)
          sb = items.first.loc.expression.source_buffer
          after_last_item = Parser::Source::Range.new(sb, begin_pos, end_pos)

          return if heredoc?(after_last_item.source)

          comma_offset = after_last_item.source =~ /,/
          should_have_comma = style == :comma && multiline?(node)
          if comma_offset
            unless should_have_comma
              avoid_comma(items, kind,
                          after_last_item.begin_pos + comma_offset, sb)
            end
          elsif should_have_comma
            put_comma(items, kind, sb)
          end
        end

        def heredoc?(source_after_last_item)
          source_after_last_item =~ /\w/
        end

        # Returns true if the node has round/square/curly brackets.
        def brackets?(node)
          !node.loc.end.nil?
        end

        # Returns true if the round/square/curly brackets of the given node are
        # on different lines.
        def multiline?(node)
          [node.loc.begin, node.loc.end].map(&:line).uniq.size > 1
        end

        def avoid_comma(items, kind, comma_begin_pos, sb)
          range = Parser::Source::Range.new(sb, comma_begin_pos,
                                            comma_begin_pos + 1)
          article = kind =~ /array/ ? 'an' : 'a'
          add_offence(nil, range,
                      sprintf(MSG, 'Avoid', sprintf(kind, article)))
        end

        def put_comma(items, kind, sb)
          last_expr = items.last.loc.expression
          ix = last_expr.source.rindex("\n") || 0
          ix += last_expr.source[ix..-1] =~ /\S/
          range = Parser::Source::Range.new(sb, last_expr.begin_pos + ix,
                                            last_expr.end_pos)
          add_offence(nil, range,
                      sprintf(MSG, 'Put a', sprintf(kind, 'a multiline')))
        end
      end
    end
  end
end
