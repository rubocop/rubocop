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
      #   # good
      #   def some_method
      #     do_stuff
      #   end
      #
      class TrailingBodyOnMethodDefinition < Cop
        include AutocorrectAlignment

        MSG = 'Method body goes below definition.'.freeze

        def on_def(node)
          return unless node.body
          return unless trailing_body?(node)

          add_offense(node)
        end
        alias on_defs on_def

        private

        def trailing_body?(node)
          node.line_count == 2 ||
            (node.line_count - node.body.line_count) == 1 &&
              node.body.to_a.first.class == AST::SendNode
        end

        def autocorrect(node)
          body = node.body

          lambda do |corrector|
            break_line_before(first_line_of(body), node, corrector, 1)

            eol_comment = end_of_line_comment(node.source_range.line)
            move_comment(eol_comment, node, corrector) if eol_comment
          end
        end

        def first_line_of(body)
          if body.begin_type?
            body.children.first.source_range
          else
            body.source_range
          end
        end

        def end_of_line_comment(line)
          processed_source.comments.find { |c| c.loc.line == line }
        end

        def break_line_before(range, node, corrector, indent_steps)
          corrector.insert_before(
            range,
            "\n" + ' ' * (node.loc.keyword.column +
                          indent_steps * configured_indentation_width)
          )
        end

        def move_comment(eol_comment, node, corrector)
          text = eol_comment.loc.expression.source
          corrector.insert_before(node.source_range,
                                  text + "\n" + (' ' * node.loc.keyword.column))
          corrector.remove(eol_comment.loc.expression)
        end
      end
    end
  end
end
