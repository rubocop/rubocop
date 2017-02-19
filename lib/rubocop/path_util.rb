# frozen_string_literal: true

module RuboCop
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

    def same_drive(path1, path2)
      if RuboCop::Platform.windows?
        regex = /^[[:alpha:]]:/
        path1_drive = path1.to_s.match(regex).to_s.downcase
        path2_drive = path2.to_s.match(regex).to_s.downcase

        path1_drive == path2_drive
      else
        true
      end
    end

    def relative_path(path, base_dir = Dir.pwd)
      # Optimization for the common case where path begins with the base
      # dir. Just cut off the first part.
      return path[(base_dir.length + 1)..-1] if path.start_with?(base_dir)

      path_name = Pathname.new(File.expand_path(path))

      if same_drive(path_name, base_dir)
        path_name.relative_path_from(Pathname.new(base_dir)).to_s
      else
        path_name.to_s
      end
    end

    def match_path?(pattern, path)
      case pattern
      when String
        File.fnmatch?(pattern, path, File::FNM_PATHNAME)
      when Regexp
        path =~ pattern
      end
    end

    # Returns true for an absolute Unix or Windows path.
    def absolute?(path)
      path =~ %r{\A([A-Z]:)?/}
    end
  end
end
