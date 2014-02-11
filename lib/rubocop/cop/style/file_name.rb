# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that Ruby source files have snake_case names.
      class FileName < Cop
        MSG = 'Use snake_case for source file names.'

        SNAKE_CASE = /^[\da-z_]+(\.rb)?$/

        def investigate(processed_source)
          filename = File.basename(processed_source.buffer.name)

          unless filename =~ SNAKE_CASE
            add_offense(nil,
                        source_range(processed_source.buffer,
                                     processed_source[0..0],
                                     0, 1))
          end
        end
      end
    end
  end
end
