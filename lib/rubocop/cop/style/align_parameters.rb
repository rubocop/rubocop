# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if the parameters on a multi-line method call are
      # aligned.
      class AlignParameters < Cop
        include AutocorrectAlignment

        MSG = 'Align the parameters of a method call if they span ' +
          'more than one line.'

        def on_send(node)
          _receiver, method, *args = *node

          return if method == :[]=
          return if args.size <= 1

          args.each_cons(2) do |prev, current|
            if current.loc.line > prev.loc.line && start_of_line?(current.loc)
              @column_delta = args.first.loc.column - current.loc.column
              convention(current, current.loc) if @column_delta != 0
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
