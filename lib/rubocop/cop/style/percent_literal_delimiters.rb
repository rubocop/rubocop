# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop enforces the consitent useage of `%`-literal delimiters.
      class PercentLiteralDelimiters < Cop
        def on_array(node)
          process(node, '%w', '%W', '%i')
        end

        def on_regexp(node)
          process(node, '%r')
        end

        def on_str(node)
          process(node, '%', '%Q', '%q')
        end
        alias_method :on_dstr, :on_str

        def on_sym(node)
          process(node, '%s')
        end

        def on_xstr(node)
          process(node, '%x')
        end

        def message(node)
          type = type(node)
          delimiters = preferred_delimiters(type)

          "`#{type}`-literals should be delimited by " \
          "`#{delimiters[0]}` and `#{delimiters[1]}`"
        end

        private

        def autocorrect(node)
          type = type(node)

          opening_delimiter, closing_delimiter = preferred_delimiters(type)
          opening_newline = new_line(node.loc.begin, node.children.first)
          closing_newline = new_line(node.loc.end, node.children.last)

          expression, reg_opt = *contents(node)
          corrected_source =
            type + opening_delimiter + opening_newline +
            expression +
            closing_newline + closing_delimiter + reg_opt

          @corrections << lambda do |corrector|
            corrector.replace(
              node.loc.expression,
              corrected_source
            )
          end
        end

        def process(node, *types)
          on_percent_literal(node, types) if percent_literal?(node)
        end

        def percent_literal?(node)
          if (begin_source = begin_source(node))
            begin_source.start_with?('%')
          end
        end

        def on_percent_literal(node, types)
          type = type(node)
          if types.include?(type) &&
              !uses_preferred_delimiter?(node, type) &&
              !contains_preferred_delimiter?(node, type)
            add_offense(node, :expression)
          end
        end

        def type(node)
          node.loc.begin.source[0..-2]
        end

        def preferred_delimiters(type)
          cop_config['PreferredDelimiters'][type].split(//)
        end

        def contents(node)
          first_child, *middle, last_child = *node
          last_child ||= first_child
          if node.type == :regexp
            *_, next_to_last_child = *middle
            next_to_last_child ||= first_child
            [
              source(node, first_child, next_to_last_child),
              last_child.loc.expression.source
            ]
          else
            [
              if first_child.is_a?(Parser::AST::Node)
                source(node, first_child, last_child)
              else
                first_child.to_s
              end,
              ''
            ]
          end
        end

        def source(node, begin_node, end_node)
          Parser::Source::Range.new(
            node.loc.expression.source_buffer,
            begin_node.loc.expression.begin_pos,
            end_node.loc.expression.end_pos
          ).source
        end

        def uses_preferred_delimiter?(node, type)
          preferred_delimiters(type)[0] == begin_source(node)[-1]
        end

        def contains_preferred_delimiter?(node, type)
          preferred_delimiters = preferred_delimiters(type)
          node
            .children.map { |n| string_source(n) }.compact
            .any? { |s| preferred_delimiters.any? { |d| s.include?(d) } }
        end

        def begin_source(node)
          if node.loc.respond_to?(:begin) && node.loc.begin
            node.loc.begin.source
          end
        end

        def string_source(node)
          if node.is_a?(String)
            node
          elsif node.respond_to?(:type) && node.type == :str
            node.loc.expression.source
          end
        end

        def new_line(range, child_node)
          same_line?(range, child_node) ? '' : "\n"
        end

        def same_line?(range, child_node)
          !child_node.is_a?(Parser::AST::Node) ||
            range.begin.line == child_node.loc.line
        end
      end
    end
  end
end
