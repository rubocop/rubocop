# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing code after the method definition.
      #
      # @example
      #   # bad
      #   def some_method; do_stuff
      #   end
      #
      #   def f(x); b = foo
      #     b[c: x]
      #   end
      #
      #   # good
      #   def some_method
      #     do_stuff
      #   end
      #
      #   def f(x)
      #     b = foo
      #     b[c: x]
      #   end
      #
      class TrailingBodyOnMethodDefinition < Cop
        include AutocorrectAlignment

        MSG = "Place the first line of a multi-line method definition's " \
              'body on its own line.'.freeze

        def on_def(node)
          return unless trailing_body?(node)

          add_offense(node, location: first_part_of(node.body))
        end
        alias on_defs on_def

        private

        def trailing_body?(node)
          node.body && node.multiline? && on_def_line?(node)
        end

        def on_def_line?(node)
          node.source_range.first_line == node.body.source_range.first_line
        end

        def autocorrect(node)
          lambda do |corrector|
            break_line_before_body(node, corrector)
            move_comment(node, corrector)
            remove_semicolon(corrector)
          end
        end

        def break_line_before_body(node, corrector)
          corrector.insert_before(
            first_part_of(node.body),
            "\n" + ' ' * (node.loc.keyword.column +
                          configured_indentation_width)
          )
        end

        def first_part_of(body)
          if body.begin_type?
            body.children.first.source_range
          else
            body.source_range
          end
        end

        def move_comment(node, corrector)
          eol_comment = end_of_line_comment(node.source_range.line)
          return unless eol_comment

          text = eol_comment.loc.expression.source
          corrector.insert_before(node.source_range,
                                  text + "\n" + (' ' * node.loc.keyword.column))
          corrector.remove(eol_comment.loc.expression)
        end

        def end_of_line_comment(line)
          processed_source.comments.find { |c| c.loc.line == line }
        end

        def remove_semicolon(corrector)
          return unless semicolon
          corrector.remove(semicolon.pos)
        end

        def semicolon
          @semicolon ||= processed_source.tokens.find do |token|
            token.line == 1 && token.type == :tSEMI
          end
        end
      end
    end
  end
end
