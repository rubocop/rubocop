# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that the opening and closing braces in a hash
      # literal either both reside on separate lines relative to the
      # hash elements, or that they both reside on a line with hash
      # elements.
      #
      # If a hash's opening brace is on the same line as the first element
      # of the hash, then the closing brace should be on the same line as
      # the last element of the hash.
      #
      # If a hash's opening brace is on the line above the first element
      # of the hash, then the closing brace should be on the line below
      # the last element of the hash.
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
          'the last hash element when the opening brace is on the same line ' \
          'as the first hash element.'.freeze

        NEW_LINE_MESSAGE = 'Closing hash brace must be on the line after ' \
          'the last hash element when opening brace is on the line before ' \
          'the first hash element.'.freeze

        def on_hash(node)
          check_brace_layout(node)
        end
      end
    end
  end
end
