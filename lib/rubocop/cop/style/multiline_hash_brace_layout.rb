# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that the closing brace in an a hash literal is
      # symmetrical with respect to the opening brace and the hash
      # elements.
      #
      # If a hash's opening brace is on the same line as the first element
      # of the hash, then the closing brace should be on the same line as
      # the last element of the hash.
      #
      # If a hash's opening brace is on a separate line from the first
      # element of the hash, then the closing brace should be on the line
      # after the last element of the hash.
      #
      # @example
      #
      #     # bad
      #     { a: 'a',
      #       b: 'b'
      #     }
      #
      #     # bad
      #     {
      #       a: 'a',
      #       b: 'b' }
      #
      #     # good
      #     { a: 'a',
      #       b: 'b' }
      #
      #     #good
      #     {
      #       a: 'a',
      #       b: 'b'
      #     }
      class MultilineHashBraceLayout < Cop
        include MultilineLiteralBraceLayout

        SAME_LINE_MESSAGE = 'Closing hash brace must be on the same line as ' \
          'the last hash element when opening brace is on the same line as ' \
          'the first hash element.'.freeze

        NEW_LINE_MESSAGE = 'Closing hash brace must be on the line after ' \
          'the last hash element when opening brace is on a separate line ' \
          'from the first hash element.'.freeze

        def on_hash(node)
          check_brace_layout(node)
        end
      end
    end
  end
end
