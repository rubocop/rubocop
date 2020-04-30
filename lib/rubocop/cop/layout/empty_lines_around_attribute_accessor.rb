# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a newline after attribute accessor.
      #
      # @example
      #   # bad
      #   attr_accessor :foo
      #   def do_something
      #   end
      #
      #   # good
      #   attr_accessor :foo
      #
      #   def do_something
      #   end
      #
      #   # good
      #   attr_accessor :foo
      #   attr_reader :bar
      #   attr_writer :baz
      #   attr :qux
      #
      #   def do_something
      #   end
      #
      class EmptyLinesAroundAttributeAccessor < Cop
        include RangeHelp

        MSG = 'Add an empty line after attribute accessor.'

        def on_send(node)
          return unless node.attribute_accessor?
          return if next_line_empty?(node.last_line)

          next_line_node = next_line_node(node)
          return if next_line_node.nil? || attribute_accessor?(next_line_node)

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            range = range_by_whole_lines(node.source_range)

            corrector.insert_after(range, "\n")
          end
        end

        private

        def next_line_empty?(line)
          processed_source[line].blank?
        end

        def next_line_node(node)
          node.parent.children[node.sibling_index + 1]
        end

        def attribute_accessor?(node)
          node.send_type? && node.attribute_accessor?
        end
      end
    end
  end
end
