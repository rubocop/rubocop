# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks if a file which has a shebang line as
      # its first line is granted execute permission.
      class ScriptPermission < Cop
        MSG = "Script file %<file>s doesn't have execute permission.".freeze
        SHEBANG = '#!'.freeze

        def investigate(processed_source)
          return if @options.key?(:stdin)
          return if Platform.windows?
          return unless processed_source.start_with?(SHEBANG)
          return if executable?(processed_source)
          comment = processed_source.comments[0]
          message = format_message_from(processed_source)
          add_offense(comment, message: message)
        end

        def autocorrect(node)
          lambda do |_corrector|
            FileUtils.chmod('+x', node.loc.expression.source_buffer.name)
          end
        end

        private

        def executable?(processed_source)
          # Returns true if stat is executable or if the operating system
          # doesn't distinguish executable files from nonexecutable files.
          # See at: https://github.com/ruby/ruby/blob/ruby_2_4/file.c#L5362
          File.stat(processed_source.file_path).executable?
        end

        def format_message_from(processed_source)
          basename = File.basename(processed_source.file_path)
          format(MSG, file: basename)
        end
      end
    end
  end
end
