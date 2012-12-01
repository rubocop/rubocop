module Rubocop
  module Cop
    class EmptyLines < Cop
      ERROR_MESSAGE = 'Use empty lines between defs.'

      def inspect(file, source, tokens, sexp)
        each_parent_of(:def, sexp) do |parent|
          # The first def doesn't need to have an empty line above it,
          # so we iterate starting at index 1.
          parent[1..-1].each { |child|
            if child[0] == :def
              # The method name is a leaf in the sexp parse tree so it
              # will have a position.
              # Example: child[1] == [:@ident, "my_method", [3, 6]]
              name_pos = child[1][-1]
              # Any errors will be reported on the lines containing
              # the method name. Normally the def keyword will be on
              # the same line.
              line_index = name_pos[0] - 1
              (line_index - 1).downto(0).each { |ix|
                case source[ix]
                when /^[ \t]*(#|private\b|public\b|protected\b)/
                  nil  # Continue searching backwards
                when /^[ \t]*$/
                  break # Empty line found, so we're ok.
                else
                  add_offence(:convention, line_index, source[line_index],
                              ERROR_MESSAGE)
                  break
                end
              }
            end
          }
        end
      end
    end
  end
end
