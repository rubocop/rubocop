# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that Ruby source files have snake_case names.
      class FileName < Cop
        MSG = 'Use snake_case for source file names.'

        SNAKE_CASE = /^[\da-z_]+$/

        def investigate(processed_source)
          file_path = processed_source.buffer.name

          return if config.file_to_include?(file_path)

          basename = File.basename(file_path).sub(/\.[^\.]+$/, '')

          unless basename =~ SNAKE_CASE
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
