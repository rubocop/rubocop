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

    def find_file_upwards(filename, start_dir, use_home: false)
      traverse_files_upwards(filename, start_dir, use_home) do |file|
        # minimize iteration for performance
        return file if file
      end
    end

    def find_files_upwards(filename, start_dir, use_home: false)
      files = []
      traverse_files_upwards(filename, start_dir, use_home) do |file|
        files << file
      end
      files
    end

    private

    def traverse_files_upwards(filename, start_dir, use_home)
      Pathname.new(start_dir).expand_path.ascend do |dir|
        break if FileFinder.root_level?(dir)
        file = dir + filename
        yield(file.to_s) if file.exist?
      end

      return unless use_home && ENV.key?('HOME')
      file = File.join(Dir.home, filename)
      yield(file) if File.exist?(file)
    end
  end
end
