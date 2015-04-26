# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop enforces the consistent usage of `%`-literal delimiters.
      class PercentLiteralDelimiters < Cop
        include PercentLiteral

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

          first_child, *_middle, last_child = *node
          opening_newline = new_line(node.loc.begin, first_child)
          expression_indentation = leading_whitespace(first_child, :expression)
          closing_newline = new_line(node.loc.end, last_child)
          closing_indentation = leading_whitespace(node, :end)
          expression, reg_opt = *contents(node)

          corrected_source =
            type + opening_delimiter + opening_newline +
            expression_indentation + expression + closing_newline +
            closing_indentation + closing_delimiter + reg_opt

          lambda do |corrector|
            corrector.replace(node.loc.expression, corrected_source)
          end
        end

        def on_percent_literal(node)
          type = type(node)
          return if uses_preferred_delimiter?(node, type) ||
                    contains_preferred_delimiter?(node, type)

          add_offense(node, :expression)
        end

        def preferred_delimiters(type)
          cop_config['PreferredDelimiters'][type].split(//)
        end

        def leading_whitespace(object, part)
          case object
          when String
            ''
          when NilClass
            ''
          when Parser::AST::Node
            part_range = object.loc.send(part)
            left_of_part = part_range.source_line[0...part_range.column]
            /^(\s*)$/.match(left_of_part) ? left_of_part : ''
          else
            fail "Unsupported object #{object}"
          end
        end

        def contents(node)
          first_child, *middle, last_child = *node
          last_child ||= first_child
          if node.type == :regexp
            *_, next_to_last_child = *middle
            next_to_last_child ||= first_child
            expression = source(node, first_child, next_to_last_child)
            reg_opt = last_child.loc.expression.source
          else
            expression = if first_child.is_a?(Parser::AST::Node)
                           source(node, first_child, last_child)
                         else
                           first_child.to_s
                         end
            reg_opt = ''
          end

          [expression, reg_opt]
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
