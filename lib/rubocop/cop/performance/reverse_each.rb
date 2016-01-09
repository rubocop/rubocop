# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of `reverse.each` and
      # change them to use `reverse_each` instead.
      #
      # @example
      #   # bad
      #   [].reverse.each
      #
      #   # good
      #   [].reverse_each
      class ReverseEach < Cop
        MSG = 'Use `reverse_each` instead of `reverse.each`.'.freeze

        def on_send(node)
          receiver, second_method = *node
          return unless second_method == :each
          return if receiver.nil?
          _, first_method = *receiver
          return unless first_method == :reverse

          source_buffer = node.source_range.source_buffer
          location_of_reverse = receiver.loc.selector.begin_pos
          end_location = node.loc.selector.end_pos

          range = Parser::Source::Range.new(source_buffer,
                                            location_of_reverse,
                                            end_location)
          add_offense(node, range, MSG)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.dot, '_') }
        end
      end
    end
  end
end
