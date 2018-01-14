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
        include Alignment

        MSG = "Place the first line of a multi-line method definition's " \
              'body on its own line.'.freeze

        def on_def(node)
          return unless trailing_body?(node)

          add_offense(node, location: first_part_of(node.body))
        end
        alias on_defs on_def

        def autocorrect(node)
          lambda do |corrector|
            LineBreakCorrector.break_line_before(
              range: first_part_of(node.body), node: node, corrector: corrector,
              configured_width: configured_indentation_width
            )
            LineBreakCorrector.move_comment(
              eol_comment: end_of_line_comment(node.source_range.line),
              node: node, corrector: corrector
            )
            remove_semicolon(node, corrector)
          end
        end

        private

        def trailing_body?(node)
          node.body && node.multiline? && on_def_line?(node)
        end

        def on_def_line?(node)
          node.source_range.first_line == node.body.source_range.first_line
        end

        def first_part_of(body)
          if body.begin_type?
            body.children.first.source_range
          else
            body.source_range
          end
        end

        def remove_semicolon(node, corrector)
          return unless semicolon(node)
          corrector.remove(semicolon(node).pos)
        end

        def semicolon(node)
          @semicolon ||= tokens(node).find(&:semicolon?)
        end
      end
    end
  end
end
