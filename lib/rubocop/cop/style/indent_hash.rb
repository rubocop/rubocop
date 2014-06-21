# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks the indentation of the first key in a hash literal
      # where the opening brace and the first key are on separate lines. The
      # other keys' indentations are handled by the AlignHash cop.
      #
      # Hash literals that are arguments in a method call with parentheses, and
      # where the opening curly brace of the hash is on the same line as the
      # opening parenthesis of the method call, shall have their first key
      # indented one step (two spaces) more than the position inside the
      # opening parenthesis.
      #
      # Other hash literals shall have their first key indented one step more
      # than the start of the line where the opening curly brace is.
      class IndentHash < Cop
        include AutocorrectAlignment
        include ConfigurableEnforcedStyle

        def on_hash(node)
          left_brace = node.loc.begin
          check(node, left_brace, nil) if left_brace
        end

        def on_send(node)
          _receiver, _method_name, *args = *node
          left_parenthesis = node.loc.begin
          return unless left_parenthesis

          args.each do |arg|
            on_node(:hash, arg, :send) do |hash_node|
              left_brace = hash_node.loc.begin
              if left_brace && left_brace.line == left_parenthesis.line
                check(hash_node, left_brace, left_parenthesis)
                ignore_node(hash_node)
              end
            end
          end
        end

        private

        def check(hash_node, left_brace, left_parenthesis)
          return if ignored_node?(hash_node)

          first_pair = hash_node.children.first
          if first_pair
            left_brace = hash_node.loc.begin
            return if first_pair.loc.expression.line == left_brace.line

            if separator_style?(first_pair)
              check_based_on_longest_key(hash_node.children, left_brace,
                                         left_parenthesis)
            else
              check_first_pair(first_pair, left_brace, left_parenthesis, 0)
            end
          end

          check_right_brace(hash_node.loc.end, left_brace, left_parenthesis)
        end

        def check_right_brace(right_brace, left_brace, left_parenthesis)
          return if right_brace.source_line[0...right_brace.column] =~ /\S/

          expected_column = base_column(left_brace, left_parenthesis)
          @column_delta = expected_column - right_brace.column
          return if @column_delta == 0

          msg = if style == :special_inside_parentheses && left_parenthesis
                  'Indent the right brace the same as the first position ' \
                  'after the preceding left parenthesis.'
                else
                  'Indent the right brace the same as the start of the line ' \
                  'where the left brace is.'
                end
          add_offense(right_brace, right_brace, msg)
        end

        def separator_style?(first_pair)
          separator = first_pair.loc.operator
          key = "Enforced#{separator.is?(':') ? 'Colon' : 'HashRocket'}Style"
          config.for_cop('Style/AlignHash')[key] == 'separator'
        end

        def check_based_on_longest_key(pairs, left_brace, left_parenthesis)
          key_lengths = pairs.map do |pair|
            pair.children.first.loc.expression.length
          end
          check_first_pair(pairs.first, left_brace, left_parenthesis,
                           key_lengths.max - key_lengths.first)
        end

        def check_first_pair(first_pair, left_brace, left_parenthesis, offset)
          column = first_pair.loc.expression.column
          expected_column = base_column(left_brace, left_parenthesis) +
                            configured_indentation_width + offset
          @column_delta = expected_column - column

          if @column_delta == 0
            correct_style_detected
          else
            incorrect_style_detected(column, offset, first_pair,
                                     left_parenthesis, left_brace)
          end
        end

        def incorrect_style_detected(column, offset, first_pair,
                                     left_parenthesis, left_brace)
          add_offense(first_pair, :expression,
                      message(base_description(left_parenthesis))) do
            if column == unexpected_column(left_brace, left_parenthesis,
                                           offset)
              opposite_style_detected
            else
              unrecognized_style_detected
            end
          end
        end

        def base_column(left_brace, left_parenthesis)
          if left_parenthesis && style == :special_inside_parentheses
            left_parenthesis.column + 1
          else
            left_brace.source_line =~ /\S/
          end
        end

        # Returns the description of what the correct indentation is based on.
        def base_description(left_parenthesis)
          if left_parenthesis && style == :special_inside_parentheses
            'the first position after the preceding left parenthesis'
          else
            'the start of the line where the left curly brace is'
          end
        end

        # Returns the "unexpected column", which is the column that would be
        # correct if the configuration was changed.
        def unexpected_column(left_brace, left_parenthesis, offset)
          # Set a crazy value by default, indicating that there's no other
          # configuration that can be chosen to make the used indentation
          # accepted.
          unexpected_base_column = -1000

          if left_parenthesis
            unexpected_base_column = if style == :special_inside_parentheses
                                       left_brace.source_line =~ /\S/
                                     else
                                       left_parenthesis.column + 1
                                     end
          end

          unexpected_base_column + configured_indentation_width + offset
        end

        def message(base_description)
          format('Use %d spaces for indentation in a hash, relative to %s.',
                 configured_indentation_width, base_description)
        end
      end
    end
  end
end
