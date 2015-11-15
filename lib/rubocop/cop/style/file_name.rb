# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop makes sure that Ruby source files have snake_case
      # names. Ruby scripts (i.e. source files with a shebang in the
      # first line) are ignored.
      class FileName < Cop
        MSG = 'Use snake_case for source file names.'

        SNAKE_CASE = /^[\da-z_]+$/

        def investigate(processed_source)
          file_path = processed_source.buffer.name
          return if config.file_to_include?(file_path)

          basename = File.basename(file_path).sub(/\.[^\.]+$/, '')
          return if snake_case?(basename)

          first_line = processed_source.lines.first
          return if cop_config['IgnoreExecutableScripts'] &&
                    shebang?(first_line)

          range = source_range(processed_source.buffer, 1, 0)
          add_offense(nil, range)
        end

        private

        def snake_case?(basename)
          basename.split('.').all? { |fragment| fragment =~ SNAKE_CASE }
        end

        def shebang?(line)
          line.start_with?('#!')
        end
      end
    end
  end
end
