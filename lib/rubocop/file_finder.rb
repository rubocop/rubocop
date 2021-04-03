# frozen_string_literal: true

require 'pathname'

module RuboCop
  # Common methods for finding files.
  # @api private
  module FileFinder
    def self.root_level=(level)
      @root_level = level
    end

    def self.root_level?(path, stop_dir)
      (@root_level || stop_dir) == path.to_s
    end

    def find_file_upwards(filename, start_dir, stop_dir = nil)
      traverse_files_upwards(filename, start_dir, stop_dir) do |file|
        # minimize iteration for performance
        return file if file
      end
    end

    def find_last_file_upwards(filename, start_dir, stop_dir = nil)
      last_file = nil
      traverse_files_upwards(filename, start_dir, stop_dir) { |file| last_file = file }
      last_file
    end

    private

    def traverse_files_upwards(filename, start_dir, stop_dir)
      Pathname.new(start_dir).expand_path.ascend do |dir|
        file = dir + filename
        yield(file.to_s) if file.exist?

        break if FileFinder.root_level?(dir, stop_dir)
      end
    end
  end
end
