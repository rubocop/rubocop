# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks whether the end statement of a do..end block
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
          return if node.single_line?

          end_loc = node.loc.end

          # If the end is on its own line, there is no offense
          return if end_loc.source_line =~ /^\s*#{end_loc.source}/

          add_offense(node, end_loc)
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            indentation = indentation_of_block_start_line(node)
            corrector.insert_before(node.loc.end, "\n" + (' ' * indentation))
          end
        end

        def message(node)
          format(MSG, node.loc.end.line, node.loc.end.column + 1)
        end

        def indentation_of_block_start_line(node)
          match = /\S.*/.match(node.loc.begin.source_line)
          match.begin(0)
        end
      end
    end
  end
end
