# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    module Layout
      # This cop checks for tabs inside the source code.
      class Tab < Cop
        MSG = 'Tab detected.'.freeze

        def investigate(processed_source)
          str_lines = string_literal_lines(processed_source.ast)

          processed_source.lines.each_with_index do |line, index|
            match = line.match(/^( *)[\t ]*\t/)
            next unless match
            next if str_lines.include?(index + 1)

            spaces = match.captures[0]
            range = source_range(processed_source.buffer,
                                 index + 1,
                                 (spaces.length)...(match.end(0)))

            add_offense(range, location: range)
          end
        end

        private

        def autocorrect(range)
          lambda do |corrector|
            corrector.replace(range, range.source.gsub(/\t/, '  '))
          end
        end

        def string_literal_lines(ast)
          # which lines start inside a string literal?
          return [] if ast.nil?

          ast.each_node(:str, :dstr).each_with_object(Set.new) do |str, lines|
            loc = str.location

            str_lines = if loc.is_a?(Parser::Source::Map::Heredoc)
                          body = loc.heredoc_body
                          (body.first_line)..(body.last_line)
                        else
                          (loc.first_line + 1)..(loc.last_line)
                        end

            lines.merge(str_lines.to_a)
          end
        end
      end
    end
  end
end
