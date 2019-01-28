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
      traverse_file(filename, start_dir).each { |f| yield(f.to_s) }
      return unless use_home && (ENV.key?('HOME') ||
                                 ENV.key?('XDG_CONFIG_HOME'))

      xdg_file = File.join(ENV['XDG_CONFIG_HOME'].to_s, filename)
      yield(xdg_file) if File.exist?(xdg_file)

      file = File.join(ENV['HOME'].to_s, filename)
      yield(file) if File.exist?(file)
    end

    def traverse_file(filename, start_dir)
      result = []
      Pathname.new(start_dir).expand_path.ascend do |dir|
        break if FileFinder.root_level?(dir)

        file = dir + filename
        result.push(file) if file.exist?
      end
      result
    end
  end
end
