# encoding: utf-8

module Rubocop
  module Cop
    class MethodLength < Cop
      ERROR_MESSAGE = 'Method has too many lines. [%d/%d]'

      def inspect(file, source, tokens, sexp)
        def_token_indices(tokens, source).each do |t_ix|
          def_lineno, end_lineno = def_and_end_lines(tokens, t_ix)
          length = calculate_length(def_lineno, end_lineno, source)

          max = MethodLength.config['Max']
          if length > max
            message = sprintf(ERROR_MESSAGE, length, max)
            add_offence(:convention, def_lineno, message)
          end
        end
      end

      private

      def calculate_length(def_lineno, end_lineno, source)
        lines = source[def_lineno..(end_lineno - 2)].reject(&:empty?)
        unless MethodLength.config['CountComments']
          lines = lines.reject { |line| line =~ /^\s*#/ }
        end
        lines.size
      end

      def def_token_indices(tokens, source)
        tokens.each_index.select do |ix|
          t = tokens[ix]

          # Need to check:
          # 1. if the previous character is a ':' to prevent matching ':def'
          # 2. if the method is a one line, which we will ignore
          [t.type, t.text] == [:on_kw, 'def'] &&
            source[t.pos.lineno - 1][t.pos.column - 1] != ':' &&
            source[t.pos.lineno - 1] !~ /^\s*def.*(?:\(.*\)|;).*end\s*$/
        end
      end

      # Find the matching 'end' based on the indentation of 'def'
      # Fall back to last token if indentation cannot be matched
      def def_and_end_lines(tokens, t_ix)
        t1 = tokens[t_ix]
        t2 = tokens[(t_ix + 1)..-1].find(-> { tokens[-1] }) do |t|
          [t1.pos.column, t.type, t.text] == [t.pos.column, :on_kw, 'end']
        end
        [t1.pos.lineno, t2.pos.lineno]
      end
    end
  end
end
