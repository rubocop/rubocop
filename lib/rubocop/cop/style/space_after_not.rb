# encoding: utf-8
# frozen_string_literal: true

module RuboCop
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
        MSG = 'Do not leave space between `!` and its argument.'.freeze

        def on_send(node)
          _receiver, method_name, *_args = *node

          return unless method_name == :!
          return unless node.source =~ /^!\s+\w+/

          # TODO: Improve source range to highlight the redundant whitespace.
          add_offense(node, :selector)
        end

        def autocorrect(node)
          lambda do |corrector|
            receiver, _method_name, *_args = *node
            space_range =
              Parser::Source::Range.new(node.loc.selector.source_buffer,
                                        node.loc.selector.end_pos,
                                        receiver.source_range.begin_pos)
            corrector.remove(space_range)
          end
        end
      end
    end
  end
end
