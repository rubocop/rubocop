# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks the indentation of the first parameter in a method call.
      # Parameters after the first one are checked by Style/AlignParameters, not
      # by this cop.
      #
      # @example
      #
      #   # bad
      #   some_method(
      #   first_param,
      #   second_param)
      #
      #   # good
      #   some_method(
      #     first_param,
      #   second_param)
      class FirstParameterIndentation < Cop
        include AutocorrectAlignment
        include ConfigurableEnforcedStyle

        def on_send(node)
          _receiver, method_name, *args = *node
          return if args.empty?
          return if operator?(method_name)

          base_indentation = if special_inner_call_indentation?(node)
                               column_of(base_range(node, args.first))
                             else
                               previous_code_line(args.first.loc.line) =~ /\S/
                             end
          check_alignment([args.first],
                          base_indentation + configured_indentation_width)
        end

        private

        def message(arg_node)
          return 'Bad indentation of the first parameter.' if arg_node.nil?

          send_node = arg_node.parent
          text = base_range(send_node, arg_node).source.strip
          base = if text !~ /\n/ && special_inner_call_indentation?(send_node)
                   "`#{text}`"
                 elsif text.lines.reverse_each.first =~ /^\s*#/
                   'the start of the previous line (not counting the comment)'
                 else
                   'the start of the previous line'
                 end
          format('Indent the first parameter one step more than %s.', base)
        end

        def special_inner_call_indentation?(node)
          return false if style == :consistent

          parent = node.parent
          return false unless parent
          return false unless parent.send_type?

          _receiver, method_name, *_args = *parent
          # :[]= is a send node, but we want to treat it as an assignment.
          return false if method_name == :[]=

          return false if !parentheses?(parent) &&
                          style == :special_for_inner_method_call_in_parentheses

          # The node must begin inside the parent, otherwise node is the first
          # part of a chained method call.
          node.source_range.begin_pos > parent.source_range.begin_pos
        end

        def base_range(send_node, arg_node)
          Parser::Source::Range.new(processed_source.buffer,
                                    send_node.source_range.begin_pos,
                                    arg_node.source_range.begin_pos)
        end

        # Returns the column of the given range. For single line ranges, this
        # is simple. For ranges with line breaks, we look a the last code line.
        def column_of(range)
          source = range.source.strip
          if source.include?("\n")
            previous_code_line(range.line + source.count("\n") + 1) =~ /\S/
          else
            display_column(range)
          end
        end

        # Takes the line number of a given code line and returns a string
        # containing the previous line that's not a comment line or a blank
        # line.
        def previous_code_line(line_number)
          @comment_lines ||=
            processed_source
            .comments
            .select { |c| begins_its_line?(c.loc.expression) }
            .map { |c| c.loc.line }

          line = ''
          while line.blank? || @comment_lines.include?(line_number)
            line_number -= 1
            line = processed_source.lines[line_number - 1]
          end
          line
        end
      end
    end
  end
end
