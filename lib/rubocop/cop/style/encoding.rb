# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks whether the source file has a
      # utf-8 encoding comment. This check makes sense only
      # in Ruby 1.9, since in 2.0+ utf-8 is the default source file
      # encoding.
      class Encoding < Cop
        MSG = 'Missing utf-8 encoding comment.'

        def source_callback(source_buffer, source, tokens, ast, comments)
          unless RUBY_VERSION >= '2.0.0'
            expected_line = 0
            expected_line += 1 if source[expected_line] =~ /^#!/
            unless source[expected_line] =~ /#.*coding\s?: (UTF|utf)-8/
              add_offence(:convention,
                          source_range(source_buffer,
                                       source[0...expected_line],
                                       0, 1),
                          MSG)
            end
          end
        end
      end
    end
  end
end
