# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    module Layout
      # This cop checks for tabs inside the source code.
      #
      # @example
      #   # bad
      #   # This example uses a tab to indent bar.
      #   def foo
      #     bar
      #   end
      #
      #   # good
      #   # This example uses spaces to indent bar.
      #   def foo
      #     bar
      #   end
      #
      class Tab < Cop
        include Alignment
        include RangeHelp

        MSG = 'Tab detected.'

        def investigate(processed_source)
          str_ranges = string_literal_ranges(processed_source.ast)

          processed_source.lines.each.with_index(1) do |line, lineno|
            match = line.match(/\t+/)
            next unless match

            range = source_range(processed_source.buffer,
                                 lineno,
                                 match.begin(0)...match.end(0))
            next if in_string_literal?(str_ranges, range)

            add_offense(range, location: range)
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            spaces = ' ' * configured_indentation_width
            corrector.replace(range, range.source.gsub(/\t/, spaces))
          end
        end

        private

        def in_string_literal?(ranges, tabs_range)
          ranges.any? { |range| range.contains?(tabs_range) }
        end

        def string_literal_ranges(ast)
          # which lines start inside a string literal?
          return [] if ast.nil?

          ast.each_node(:str, :dstr).each_with_object(Set.new) do |str, ranges|
            loc = str.location

            if str.heredoc?
              ranges << loc.heredoc_body
            elsif loc.respond_to?(:begin) && loc.begin
              ranges << loc.expression
            end
          end
        end
      end
    end
  end
end
