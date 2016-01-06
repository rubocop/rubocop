# encoding: utf-8
# frozen_string_literal: true

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
        UNDERSCORE = '_'.freeze

        def_node_matcher :reverse_each?, <<-MATCHER
          (send $(send array :reverse) :each)
        MATCHER

        def on_send(node)
          reverse_each?(node) do |receiver|
            source_buffer = node.source_range.source_buffer
            location_of_reverse = receiver.loc.selector.begin_pos
            end_location = node.loc.selector.end_pos

            range = Parser::Source::Range.new(source_buffer,
                                              location_of_reverse,
                                              end_location)
            add_offense(node, range, MSG)
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.dot, UNDERSCORE) }
        end
      end
    end
  end
end
