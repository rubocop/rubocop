# encoding: utf-8
# frozen_string_literal: true

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
            raise ValidationError,
                  'The `Style/MultilineMethodCallIndentation`' \
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
                             @base.column + extra_indentation(given_style)
                           else
                             indentation(lhs) + correct_indentation(node)
                           end
          @column_delta = correct_column - rhs.column
          rhs if @column_delta != 0
        end

        def extra_indentation(given_style)
          if given_style == :indented_relative_to_receiver
            configured_indentation_width
          else
            0
          end
        end

        def message(node, lhs, rhs)
          if @base
            base_source = @base.source[/[^\n]*/]
            if style == :indented_relative_to_receiver
              "Indent `#{rhs.source}` #{configured_indentation_width} spaces " \
              "more than `#{base_source}` on line #{@base.line}."
            else
              "Align `#{rhs.source}` with `#{base_source}` on " \
              "line #{@base.line}."
            end
          else
            used_indentation = rhs.column - indentation(lhs)
            what = operation_description(node, rhs)
            "Use #{correct_indentation(node)} (not #{used_indentation}) " \
              "spaces for indenting #{what} spanning multiple lines."
          end
        end

        def alignment_base(node, rhs, given_style)
          return nil if given_style == :indented

          if given_style == :indented_relative_to_receiver
            receiver_base = receiver_alignment_base(node)
            return receiver_base if receiver_base
          end

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
          return unless rhs.source.start_with?('.')

          node = semantic_alignment_node(node)
          return unless node

          node.loc.dot.join(node.loc.selector)
        end

        # a
        #   .b
        #   .c
        def receiver_alignment_base(node)
          node = semantic_alignment_node(node)
          return unless node

          node.receiver.source_range
        end

        def semantic_alignment_node(node)
          return if argument_in_method_call(node)

          # descend to root of method chain
          node = node.receiver while node.receiver
          # ascend to first call which has a dot
          node = node.parent
          node = node.parent until node.loc.dot

          return if node.loc.dot.line != node.loc.line
          node
        end

        def operation_rhs(node)
          receiver, = *node
          receiver.each_ancestor(:send) do |a|
            _, method, args = *a
            return args if operator?(method) && args &&
                           within_node?(receiver, args)
          end
          nil
        end
      end
    end
  end
end
