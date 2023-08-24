# frozen_string_literal: true

require 'pathname'

module RuboCop
  # Common methods for finding files.
  # @api private
  module FileFinder
    class << self
      attr_accessor :root_level
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

        dir = dir.to_s
        break if dir == stop_dir || dir == FileFinder.root_level
      end
    end
  end
end
