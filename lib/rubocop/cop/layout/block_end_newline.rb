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
        include Alignment

        MSG = 'Expression at %<line>d, %<column>d should be on its own line.'
              .freeze

        def on_block(node)
          return if node.single_line?

          end_loc = node.loc.end

          # If the end is on its own line, there is no offense
          return if end_loc.source_line =~ /^\s*#{end_loc.source}/

          add_offense(node, location: end_loc)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(delimiter_range(node),
                              "\n#{node.loc.end.source}#{offset(node)}")
          end
        end

        private

        def message(node)
          format(MSG, line: node.loc.end.line, column: node.loc.end.column + 1)
        end

        def delimiter_range(node)
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    node.children.last.loc.expression.end_pos,
                                    node.loc.expression.end_pos)
        end
      end
    end
  end
end
