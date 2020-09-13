# frozen_string_literal: true

module RuboCop
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

    def relative_path(path, base_dir = Dir.pwd)
      # Optimization for the common case where path begins with the base
      # dir. Just cut off the first part.
      if path.start_with?(base_dir)
        base_dir_length = base_dir.length
        result_length = path.length - base_dir_length - 1
        return path[base_dir_length + 1, result_length]
      end

      path_name = Pathname.new(File.expand_path(path))
      begin
        path_name.relative_path_from(Pathname.new(base_dir)).to_s
      rescue ArgumentError
        path
      end
    end

    def smart_path(path)
      # Ideally, we calculate this relative to the project root.
      base_dir = Dir.pwd

      if path.start_with? base_dir
        relative_path(path, base_dir)
      else
        path
      end
    end

    def match_path?(pattern, path)
      case pattern
      when String
        File.fnmatch?(pattern, path, File::FNM_PATHNAME | File::FNM_EXTGLOB) ||
          hidden_file_in_not_hidden_dir?(pattern, path)
      when Regexp
        begin
          pattern.match?(path)
        rescue ArgumentError => e
          return false if e.message.start_with?('invalid byte sequence')

          raise e
        end
      end
    end

    # Returns true for an absolute Unix or Windows path.
    def absolute?(path)
      %r{\A([A-Z]:)?/}i.match?(path)
    end

    def hidden_file_in_not_hidden_dir?(pattern, path)
      hidden_file?(path) &&
        File.fnmatch?(
          pattern, path,
          File::FNM_PATHNAME | File::FNM_EXTGLOB | File::FNM_DOTMATCH
        ) &&
        !hidden_dir?(path)
    end

    def hidden_file?(path)
      maybe_hidden_file?(path) && File.basename(path).start_with?('.')
    end

    # Loose check to reduce memory allocations
    def maybe_hidden_file?(path)
      separator_index = path.rindex(File::SEPARATOR)
      return false unless separator_index

      dot_index = path.index('.', separator_index + 1)
      dot_index == separator_index + 1
    end

    def hidden_dir?(path)
      File.dirname(path).split(File::SEPARATOR).any? do |dir|
        dir.start_with?('.')
      end
    end
  end
end
