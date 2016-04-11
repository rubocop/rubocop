# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

    def relative_path(path, base_dir = Dir.pwd)
      # Optimization for the common case where path begins with the base
      # dir. Just cut off the first part.
      return path[(base_dir.length + 1)..-1] if path.start_with?(base_dir)

      path_name = Pathname.new(File.expand_path(path))
      path_name.relative_path_from(Pathname.new(base_dir)).to_s
    end

    def match_path?(pattern, path)
      case pattern
      when String
        File.fnmatch?(pattern, path, File::FNM_PATHNAME)
      when Regexp
        path =~ pattern
      end
    end

    def hidden?(path_component)
      path_component =~ /^\.[^.]/
    end

    # Returns true for an absolute Unix or Windows path.
    def absolute?(path)
      path =~ %r{\A([A-Z]:)?/}
    end
  end
end
