# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for space after `!`.
      #
      # @example
      #   # bad
      #   ! something
      #
      #   # good
      #   !something
      class SpaceAfterNot < Cop
        MSG = 'Do not leave space between `!` and its argument.'

        def on_send(node)
          _receiver, method_name, *_args = *node

          return unless method_name == :!

          if node.loc.expression.source =~ /^!\s+\w+/
            # TODO: Improve source range to highlight the redundant whitespace.
            add_offence(node, :selector)
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            receiver, _method_name, *_args = *node
            space_range =
              Parser::Source::Range.new(node.loc.selector.source_buffer,
                                        node.loc.selector.end_pos,
                                        receiver.loc.expression.begin_pos)
            corrector.remove(space_range)
          end
        end
      end
    end
  end
end
