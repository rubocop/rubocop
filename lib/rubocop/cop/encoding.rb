# encoding: utf-8

module Rubocop
  module Cop
    class Encoding < Cop
      MSG = 'Missing utf-8 encoding comment.'

      def inspect(source, tokens, ast, comments)
        unless RUBY_VERSION >= '2.0.0'
          expected_line = 0
          expected_line += 1 if source[expected_line] =~ /^#!/
          unless source[expected_line] =~ /#.*coding: (UTF|utf)-8/
            add_offence(:convention, 1, MSG)
          end
        end
      end
    end
  end
end
