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

        def investigate(processed_source)
          unless RUBY_VERSION >= '2.0.0'
            line_number = 0
            line_number += 1 if processed_source[line_number] =~ /^#!/
            line = processed_source[line_number]
            unless line =~ /#.*coding\s?[:=]\s?(UTF|utf)-8/
              add_offence(nil,
                          source_range(processed_source.buffer,
                                       processed_source[0...line_number],
                                       0, 1),
                          MSG)
            end
          end
        end
      end
    end
  end
end
