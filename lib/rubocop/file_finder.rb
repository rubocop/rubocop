# frozen_string_literal: true

require 'pathname'

module RuboCop
  # Common methods for finding files.
  # @api private
  module FileFinder
    class << self
      # Root level defines the absolute path of the top level directory
      # that can be searched for files.
      #
      # If the start_dir is not a subdirectory of root_level, root_level is ignored.
      #
      # root_level is only used in tests to avoid finding files in directories
      # outside of the isolated test directory, especially on Windows where
      # the temporary directory is under the user's home directory.
      attr_accessor :root_level
    end

    def find_file_upwards(filename, start_dir, stop_dir = nil)
      files_upwards(filename, start_dir, stop_dir).first
    end

    def find_last_file_upwards(filename, start_dir, stop_dir = nil)
      files_upwards(filename, start_dir, stop_dir).to_a.last
    end

    def files_upwards(filename, start_dir, stop_dir = nil)
      return enum_for(:files_upwards, filename, start_dir, stop_dir) unless block_given?

      stop_dirs = [stop_dir, FileFinder.root_level].compact.map { |dir| File.expand_path(dir) }
      Pathname.new(start_dir).expand_path.ascend do |dir|
        file = dir + filename
        yield(file.to_s) if file.exist?

        break if stop_dirs.include?(dir.to_s)
      end
    end
  end
end
