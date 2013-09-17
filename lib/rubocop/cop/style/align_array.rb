# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if the elements of a multi-line array literal are
      # aligned.
      class AlignArray < Cop
        include AutocorrectAlignment

        MSG = 'Align the elements of an array literal if they span more ' +
          'than one line.'

        def on_array(node)
          first_element = node.children.first

          node.children.each_cons(2) do |prev, current|
            if current.loc.line != prev.loc.line
              @column_delta = first_element.loc.column - current.loc.column
              if current.loc.column != first_element.loc.column
                convention(current, :expression)
              end
            end
          end
        end
      end
    end
  end
end
