# frozen_string_literal: true

module RuboCop
  # Common methods for searching file upwards in the directory structure.
  module Pathfinder
    private

    def files_in_path(target_path, target_file)
      files = dirs_to_search(target_path).map do |dir|
        File.join(dir, target_file)
      end
      files.select { |file| File.exist?(file) }
    end

    def dirs_to_search(target_dir)
      dirs = []
      Pathname.new(File.expand_path(target_dir)).ascend do |dir_pathname|
        break if dir_pathname.to_s == @root_level
        dirs << dir_pathname.to_s
      end
      dirs << Dir.home if ENV.key? 'HOME'
      dirs
    end
  end
end
