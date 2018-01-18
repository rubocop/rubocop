# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing code after the module definition.
      #
      # @example
      #   # bad
      #   module Foo extend self
      #   end
      #
      #   # good
      #   module Foo
      #     extend self
      #   end
      #
      class TrailingBodyOnModule < Cop
        include Alignment
        include TrailingBody

        MSG = 'Place the first line of module body on its own line.'.freeze

        def on_module(node)
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
