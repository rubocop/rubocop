# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether the end statement of a do end blocks
      # is on its own line.
      #
      # @example
      #   # bad
      #   blah do |i|
      #     foo(i) end
      #
      #   # good
      #   blah do |i|
      #     foo(i)
      #   end
      #
      #   # bad
      #   blah { |i|
      #     foo(i) }
      #
      #   # good
      #   blah { |i|
      #     foo(i)
      #   }
      class BlockEndNewline < Cop
        MSG = 'Expression at %d, %d should be on its own line.'.freeze

        def on_block(node)
          end_loc = node.loc.end
          do_loc = node.loc.begin # Actually it's either do or {.
          return if do_loc.line == end_loc.line # Ignore one-liners.

          # If the end is on its own line, there is no offense
          return if end_loc.source_line =~ /^\s*#{end_loc.source}/

          msg = format(MSG, end_loc.line, end_loc.column + 1)
          add_offense(node, end_loc, msg)
        end

        def autocorrect(node)
          lambda do |corrector|
            indentation = indentation_of_block_start_line(node)
            corrector.insert_before(node.loc.end, "\n" + (' ' * indentation))
          end
        end

        def indentation_of_block_start_line(node)
          match = /\S.*/.match(node.loc.begin.source_line)
          match.begin(0)
        end
      end
    end
  end
end
