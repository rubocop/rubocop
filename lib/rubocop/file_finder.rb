# frozen_string_literal: true

module RuboCop
  # Common methods for finding files.
  module FileFinder
    def self.root_level=(level)
      @root_level = level
    end

    def self.root_level?(path)
      @root_level == path.to_s
    end

    def find_file_upwards(filename, start_dir, home_dir: false)
      traverse_files_upwards(filename, start_dir, home_dir) do |file|
        # minimize iteration for performance
        return file if file
      end
    end

    def find_files_upwards(filename, start_dir, home_dir: false)
      files = []
      traverse_files_upwards(filename, start_dir, home_dir) do |file|
        files << file
      end
      files
    end

    private

    def traverse_files_upwards(filename, start_dir, home_dir)
      Pathname.new(start_dir).expand_path.ascend do |dir|
        file = dir + filename
        yield(file.to_s) if file.exist?
        break if FileFinder.root_level?(dir)
      end

      return unless home_dir && ENV.key?('HOME')
      file = File.join(Dir.home, filename)
      yield(file) if File.exist?(file)
    end
  end
end
