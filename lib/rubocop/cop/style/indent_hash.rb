# encoding: utf-8

module Rubocop
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

        def on_hash(node)
          left_brace = node.loc.begin
          if left_brace
            check(node, left_brace.source_line =~ /\S/,
                  'the start of the line where the left curly brace is')
          end
        end

        def on_send(node)
          _receiver, _method_name, *args = *node
          left_parenthesis = node.loc.begin
          return unless left_parenthesis

          args.each do |arg|
            on_node(:hash, arg, :send) do |hash_node|
              left_brace = hash_node.loc.begin
              if left_brace && left_brace.line == left_parenthesis.line
                check(hash_node, left_parenthesis.column + 1,
                      'the first position after the preceding left ' \
                      'parenthesis')
              end
            end
          end
        end

        private

        def check(hash_node, base_column, base_description)
          return if ignored_node?(hash_node)

          first_pair = hash_node.children.first
          return if first_pair.nil?

          left_brace = hash_node.loc.begin
          return if first_pair.loc.expression.line == left_brace.line

          expected_column = base_column + IndentationWidth::CORRECT_INDENTATION
          @column_delta = expected_column - first_pair.loc.expression.column
          if @column_delta != 0
            add_offense(first_pair, :expression, message(base_description))
          end
          ignore_node(hash_node)
        end

        def message(base_description)
          format('Use %d spaces for indentation in a hash, relative to %s.',
                 IndentationWidth::CORRECT_INDENTATION, base_description)
        end
      end
    end
  end
end
