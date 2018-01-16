# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing code after the class definition.
      #
      # @example
      #   # bad
      #   class Foo; def foo; end
      #   end
      #
      #   # good
      #   class Foo
      #     def foo; end
      #   end
      #
      class TrailingBodyOnClass < Cop
        include Alignment
        include TrailingBody

        MSG = 'Place the first line of class body on its own line.'.freeze

        def on_class(node)
          return unless trailing_body?(node)

          add_offense(node, location: first_part_of(node.to_a.last))
        end

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
