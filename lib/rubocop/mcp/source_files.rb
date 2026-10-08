# frozen_string_literal: true

module RuboCop
  module MCP
    # Reads and writes the files the tools work on. A file that can't be read
    # or written fails the request with an error the agent can act on.
    # @api private
    module SourceFiles
      module_function

      def read(file, config)
        RuboCop::ProcessedSource.from_file(
          file, config.target_ruby_version, parser_engine: config.parser_engine
        ).raw_source
      rescue Errno::ENOENT
        raise RuboCop::Error, "No such file or directory: #{file}"
      end

      # Writing what a file already holds would only bump its modification time.
      def write(file, content)
        return if File.file?(file) && File.binread(file) == content.b

        Util.replace_file_contents(file, content)
      rescue Errno::EACCES
        raise RuboCop::Error, "Permission denied: #{file}"
      rescue Errno::ENOSPC
        raise RuboCop::Error, "No space left on device: #{file}"
      rescue Errno::EROFS
        raise RuboCop::Error, "Read-only file system: #{file}"
      end
    end
  end
end
