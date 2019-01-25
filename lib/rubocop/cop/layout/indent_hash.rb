# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the indentation of the first key in a hash literal
      # where the opening brace and the first key are on separate lines. The
      # other keys' indentations are handled by the AlignHash cop.
      #
      # By default, Hash literals that are arguments in a method call with
      # parentheses, and where the opening curly brace of the hash is on the
      # same line as the opening parenthesis of the method call, shall have
      # their first key indented one step (two spaces) more than the position
      # inside the opening parenthesis.
      #
      # Other hash literals shall have their first key indented one step more
      # than the start of the line where the opening curly brace is.
      #
      # This default style is called 'special_inside_parentheses'. Alternative
      # styles are 'consistent' and 'align_braces'. Here are examples:
      #
      # @example EnforcedStyle: special_inside_parentheses (default)
      #   # The `special_inside_parentheses` style enforces that the first key
      #   # in a hash literal where the opening brace and the first key are on
      #   # separate lines is indented one step (two spaces) more than the
      #   # position inside the opening parentheses.
      #
      #   # bad
      #   hash = {
      #     key: :value
      #   }
      #   and_in_a_method_call({
      #     no: :difference
      #                        })
      #
      #   # good
      #   special_inside_parentheses
      #   hash = {
      #     key: :value
      #   }
      #   but_in_a_method_call({
      #                          its_like: :this
      #                        })
      #
      # @example EnforcedStyle: consistent
      #   # The `consistent` style enforces that the first key in a hash
      #   # literal where the opening brace and the first key are on
      #   # separate lines is indented the same as a hash literal which is not
      #   # defined inside a method call.
      #
      #   # bad
      #   hash = {
      #     key: :value
      #   }
      #   but_in_a_method_call({
      #                          its_like: :this
      #                         })
      #
      #   # good
      #   hash = {
      #     key: :value
      #   }
      #   and_in_a_method_call({
      #     no: :difference
      #   })
      #
      # @example EnforcedStyle: align_braces
      #   # The `align_brackets` style enforces that the opening and closing
      #   # braces are indented to the same position.
      #
      #   # bad
      #   and_now_for_something = {
      #                             completely: :different
      #   }
      #
      #   # good
      #   and_now_for_something = {
      #                             completely: :different
      #                           }
      class IndentHash < Cop
        include Alignment
        include ConfigurableEnforcedStyle
        include ArrayHashIndentation

        MSG = 'Use %<configured_indentation_width>d spaces for indentation ' \
              'in a hash, relative to %<base_description>s.'.freeze

        def on_hash(node)
          check(node, nil) if node.loc.begin
        end

        def on_send(node)
          each_argument_node(node, :hash) do |hash_node, left_parenthesis|
            check(hash_node, left_parenthesis)
          end
        end
        alias on_csend on_send

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, @column_delta)
        end

        private

        def brace_alignment_style
          :align_braces
        end

        def check(hash_node, left_parenthesis)
          return if ignored_node?(hash_node)

          left_brace = hash_node.loc.begin
          first_pair = hash_node.pairs.first

          if first_pair
            return if first_pair.source_range.line == left_brace.line

            if separator_style?(first_pair)
              check_based_on_longest_key(hash_node, left_brace,
                                         left_parenthesis)
            else
              check_first(first_pair, left_brace, left_parenthesis, 0)
            end
          end

          check_right_brace(hash_node.loc.end, left_brace, left_parenthesis)
        end

        def check_right_brace(right_brace, left_brace, left_parenthesis)
          # if the right brace is on the same line as the last value, accept
          return if right_brace.source_line[0...right_brace.column] =~ /\S/

          expected_column = base_column(left_brace, left_parenthesis)
          @column_delta = expected_column - right_brace.column
          return if @column_delta.zero?

          msg = if style == :align_braces
                  'Indent the right brace the same as the left brace.'
                elsif style == :special_inside_parentheses && left_parenthesis
                  'Indent the right brace the same as the first position ' \
                  'after the preceding left parenthesis.'
                else
                  'Indent the right brace the same as the start of the line ' \
                  'where the left brace is.'
                end
          add_offense(right_brace, location: right_brace, message: msg)
        end

        def separator_style?(first_pair)
          separator = first_pair.loc.operator
          key = "Enforced#{separator.is?(':') ? 'Colon' : 'HashRocket'}Style"
          config.for_cop('Layout/AlignHash')[key] == 'separator'
        end

        def check_based_on_longest_key(hash_node, left_brace, left_parenthesis)
          key_lengths = hash_node.keys.map do |key|
            key.source_range.length
          end
          check_first(hash_node.pairs.first, left_brace, left_parenthesis,
                      key_lengths.max - key_lengths.first)
        end

        # Returns the description of what the correct indentation is based on.
        def base_description(left_parenthesis)
          if style == :align_braces
            'the position of the opening brace'
          elsif left_parenthesis && style == :special_inside_parentheses
            'the first position after the preceding left parenthesis'
          else
            'the start of the line where the left curly brace is'
          end
        end

        def message(base_description)
          format(
            MSG,
            configured_indentation_width: configured_indentation_width,
            base_description: base_description
          )
        end
      end
    end
  end
end
