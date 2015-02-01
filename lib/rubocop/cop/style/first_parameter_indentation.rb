# encoding: utf-8

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
                               base_range(node, args.first).column
                             else
                               node.loc.expression.source_line =~ /\S/
                             end
          check_alignment([args.first],
                          base_indentation + configured_indentation_width)
        end

        private

        def message(arg_node)
          send_node = arg_node.parent
          base = if special_inner_call_indentation?(send_node)
                   text = base_range(send_node, arg_node).source.strip
                          .sub(/\n.*/, '')
                          .chomp('(')
                   "`#{text}`"
                 else
                   'the previous line'
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
          node.loc.expression.begin_pos > parent.loc.expression.begin_pos
        end

        def base_range(send_node, arg_node)
          Parser::Source::Range.new(processed_source.buffer,
                                    send_node.loc.expression.begin_pos,
                                    arg_node.loc.expression.begin_pos)
        end
      end
    end
  end
end
