# encoding: utf-8

module Rubocop
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

    def relative_path(path, base_dir = Dir.pwd)
      Pathname.new(path).relative_path_from(Pathname.new(base_dir)).to_s
    end

    def match_path?(pattern, path)
      case pattern
      when String
        basename = File.basename(path)
        path == pattern || basename == pattern || File.fnmatch(pattern, path)
      when Regexp
        path =~ pattern
      end
    end
  end
end
