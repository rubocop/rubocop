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
            if current.loc.line > prev.loc.line && start_of_line?(current.loc)
              @column_delta = first_element.loc.column - current.loc.column
              convention(current, :expression) if @column_delta != 0
            end
          end
        end

        private

        def start_of_line?(loc)
          loc.expression.source_line[0...loc.column] =~ /^\s*$/
        end
      end
    end
  end
end
