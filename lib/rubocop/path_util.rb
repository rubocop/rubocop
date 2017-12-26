# frozen_string_literal: true

module RuboCop
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

    def relative_path(path, base_dir = PathUtil.pwd)
      # Optimization for the common case where path begins with the base
      # dir. Just cut off the first part.
      if path.start_with?(base_dir)
        base_dir_length = base_dir.length
        result_length = path.length - base_dir_length - 1
        return path[base_dir_length + 1, result_length]
      end

      path_name = Pathname.new(File.expand_path(path))
      path_name.relative_path_from(Pathname.new(base_dir)).to_s
    end

    def smart_path(path)
      # Ideally, we calculate this relative to the project root.
      base_dir = PathUtil.pwd

      if path.start_with? base_dir
        relative_path(path, base_dir)
      else
        path
      end
    end

    def match_path?(pattern, path)
      case pattern
      when String
        File.fnmatch?(pattern, path, File::FNM_PATHNAME)
      when Regexp
        begin
          path =~ pattern
        rescue ArgumentError => e
          return false if e.message.start_with?('invalid byte sequence')
          raise e
        end
      end
    end

    def find_file_upwards(filename, start_dir = PathUtil.pwd)
      Pathname(File.expand_path(start_dir)).ascend do |dir|
        file = File.join(dir, filename)
        return file if File.exist?(file)
      end
    end

    # Returns true for an absolute Unix or Windows path.
    def absolute?(path)
      path =~ %r{\A([A-Z]:)?/}
    end

    def self.pwd
      @pwd ||= Dir.pwd
    end

    def self.reset_pwd
      @pwd = nil
    end
  end
end
