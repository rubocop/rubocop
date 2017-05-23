# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks if a file which has a shebang line as
      # its first line is granted execute permission.
      class ScriptPermission < Cop
        MSG = "Script file %s doesn't have execute permission.".freeze
        SHEBANG = '#!'.freeze

        def investigate(processed_source)
          return if Platform.windows?
          return unless start_with_shebang?(processed_source)
          return if executable?(processed_source)
          comment = processed_source.comments[0]
          message = format_message_from(processed_source)
          add_offense(comment, :expression, message)
        end

        private

        def start_with_shebang?(processed_source)
          return false if processed_source[0].nil?
          processed_source[0].start_with?(SHEBANG)
        end

        def executable?(processed_source)
          # Returns true if stat is executable or if the operating system
          # doesn't distinguish executable files from nonexecutable files.
          # See at: https://github.com/ruby/ruby/blob/ruby_2_4/file.c#L5362
          File.stat(processed_source.buffer.name).executable?
        end

        def format_message_from(processed_source)
          basename = File.basename(processed_source.buffer.name)
          format(MSG, basename)
        end
      end
    end
  end
end
