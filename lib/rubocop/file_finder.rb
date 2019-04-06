# frozen_string_literal: true

require 'pathname'

module RuboCop
  # Common methods for finding files.
  module FileFinder
    def self.root_level=(level)
      @root_level = level
    end

    def self.root_level?(path)
      @root_level == path.to_s
    end

    def find_file_upwards(filename, start_dir)
      traverse_files_upwards(filename, start_dir) do |file|
        # minimize iteration for performance
        return file if file
      end
    end

    def find_files_upwards(filename, start_dir)
      files = []
      traverse_files_upwards(filename, start_dir) do |file|
        files << file
      end
      files
    end

    private

    def traverse_files_upwards(filename, start_dir)
      Pathname.new(start_dir).expand_path.ascend do |dir|
        break if FileFinder.root_level?(dir)

        file = dir + filename
        yield(file.to_s) if file.exist?
      end
    end
  end
end
