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
        include TrailingBody

        MSG = "Place the first line of a multi-line method definition's " \
              'body on its own line.'

        def on_def(node)
          return unless trailing_body?(node)

          add_offense(node, location: first_part_of(node.body))
        end
        alias on_defs on_def

        def autocorrect(node)
          lambda do |corrector|
            LineBreakCorrector.correct_trailing_body(
              configured_width: configured_indentation_width,
              corrector: corrector,
              node: node,
              processed_source: processed_source
            )
          end
        end
      end
    end
  end
end
