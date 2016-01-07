# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks the indentation of the method name part in method calls
      # that span more than one line.
      #
      # @example
      #   # bad
      #   while a
      #   .b
      #     something
      #   end
      #
      #   # good, EnforcedStyle: aligned
      #   while a
      #         .b
      #     something
      #   end
      #
      #   # good, EnforcedStyle: aligned
      #   Thing.a
      #        .b
      #        .c
      #
      #   # good, EnforcedStyle: indented
      #   while a
      #       .b
      #     something
      #   end
      class MultilineMethodCallIndentation < Cop
        include ConfigurableEnforcedStyle
        include AutocorrectAlignment
        include MultilineExpressionIndentation

        def validate_config
          if style == :aligned && cop_config['IndentationWidth']
            fail ValidationError, 'The `Style/MultilineMethodCallIndentation`' \
                                  ' cop only accepts an `IndentationWidth` ' \
                                  'configuration parameter when ' \
                                  '`EnforcedStyle` is `indented`.'
          end
        end

        private

        def relevant_node?(send_node)
          send_node.loc.dot # Only check method calls with dot operator
        end

        def offending_range(node, lhs, rhs, given_style)
          return false unless begins_its_line?(rhs)
          return false if not_for_this_cop?(node)

          @base = alignment_base(node, rhs, given_style)
          correct_column = if @base
                             @base.column
                           else
                             indentation(lhs) + correct_indentation(node)
                           end
          @column_delta = correct_column - rhs.column
          rhs if @column_delta != 0
        end

        def message(node, lhs, rhs)
          what = operation_description(node, rhs)
          if @base
            "Align `#{rhs.source}` with `#{@base.source[/[^\n]*/]}` on " \
              "line #{@base.line}."
          else
            used_indentation = rhs.column - indentation(lhs)
            "Use #{correct_indentation(node)} (not #{used_indentation}) " \
              "spaces for indenting #{what} spanning multiple lines."
          end
        end

        def alignment_base(node, rhs, given_style)
          return nil unless given_style == :aligned

          semantic_alignment_base(node, rhs) ||
            syntactic_alignment_base(node, rhs)
        end

        def syntactic_alignment_base(lhs, rhs)
          # a if b
          #      .c
          n = kw_node_with_special_indentation(lhs)
          if n
            case n.type
            when :if, :while, :until then expression, = *n
            when :for                then _, expression, = *n
            when :return             then expression, = *n
            end
            return expression.source_range
          end

          # a = b
          #     .c
          n = part_of_assignment_rhs(lhs, rhs)
          return assignment_rhs(n).source_range if n

          # a + b
          #     .c
          n = operation_rhs(lhs)
          return n.source_range if n
        end

        # a.b
        #  .c
        def semantic_alignment_base(node, rhs)
          return nil unless rhs.source.start_with?('.')
          return nil if argument_in_method_call(node)

          node, = *node while node.send_type? && node.loc.dot ||
                              node.block_type?
          return nil unless node.parent.send_type?

          first_send = node.parent
          return nil if first_send.loc.dot.line != first_send.loc.line

          first_send.loc.dot.join(first_send.loc.selector)
        end

        def operation_rhs(node)
          receiver, = *node
          receiver.each_ancestor.select(&:send_type?).each do |a|
            _, method, args = *a
            return args if operator?(method) && within_node?(receiver, args)
          end
          nil
        end
      end
    end
  end
end
