# frozen_string_literal: true

module RuboCop
  # Common methods for searching file upwards in the directory structure.
  module FileFinder
    private

    def files_in_path(target_path, target_file)
      dirs_to_search(target_path).each_with_object([]) do |dir, files|
        file = File.join(dir, target_file)
        files << file if File.exist?(file)
      end
    end

    def dirs_to_search(target_dir)
      dirs = Set.new
      Pathname.new(File.expand_path(target_dir)).ascend do |dir_pathname|
        break if dir_pathname.to_s == @root_level
        dirs << dir_pathname.to_s
      end
      dirs << Dir.home if ENV.key? 'HOME'
      dirs.to_a
    end
  end
end
